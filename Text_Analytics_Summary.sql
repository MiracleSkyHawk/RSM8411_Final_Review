--------------------------------------------
/* Array */

-- Concatenate 
ARRAY_CAT(ARRAY[1, 2], ARRAY[3, 4])

ARRAY[1, 2] || ARRAY[3, 4]

-- Append a value to an array
ARRAY_APPEND(ARRAY[1, 2], 3)

ARRAY[1, 2] || 3

-- Check if a value is contained in an array
3 = ANY(ARRAY[1, 2])

-- Check if two arrays overlap
ARRAY[1, 2, 3] && ARRAY[3, 4]

-- Check if any array contains another array
ARRAY[1, 2, 3] @> ARRAY[1, 2]

--------------------------------------------
/* String & Array */

-- Split a string to an array
SELECT STRING_TO_ARRAY('Great scooter -it is so fast.', ' '); --"{Great,scooter,-it,is,so,fast.}"

-- Concatenate an array of strings into a string
SELECT ARRAY_TO_STRING(ARRAY['Lemon', 'Bat Limited Edition'], ', ')  
AS example_purchased_products;


--------------------------------------------
/* Pivot */

-- ARRAY_AGG. Pivot rows to an array column
SELECT product_type, 
ARRAY_AGG(DISTINCT model) AS models 
FROM products 
GROUP BY 1;

-- UNNEST. Pivot am array to rows
SELECT UNNEST(ARRAY[123, 456, 789]) 
AS example_ids;

SELECT UNNEST(STRING_TO_ARRAY(feedback, ' ')) AS word, rating 
FROM customer_survey;

--------------------------------------------
/* POSIX Basic Regular Expression */
-- https://en.wikibooks.org/wiki/Regular_Expressions/POSIX_Basic_Regular_Expressions

-- Remove Punctuation
SELECT REGEXP_REPLACE('Great scooter -it is so fast.', '[!,.?-]', ' ', 'g');

SELECT REGEXP_REPLACE( REGEXP_REPLACE( 'Great scooter - it is so fast.', '[!,.?-]', ' ', 'g'), ' +', ' ', 'g');

SELECT REGEXP_REPLACE('Great scooter -it is so fast.', '[[:punct:]]', ' ', 'g');

--------------------------------------------
/* Identifying root stems (lexeme) of a token */

-- TS_LEXIZE
SELECT TS_LEXIZE('english_stem', 'running'); -- run

-- Example
SELECT
    (TS_LEXIZE(
        'english_stem', 
        UNNEST(
            STRING_TO_ARRAY(
                REGEXP_REPLACE(
                    feedback,'[^a-zA-Z]+', ' ', 'g'), ' '
            )
        )
    ))[1] AS token,rating
FROM customer_survey;

--------------------------------------------
/* LIKE and ILIKE */

-- LIKE
-- case sensitive
SELECT
    'foo' LIKE 'foo', -- true
    'foo' LIKE 'f%', -- true
    'foo' LIKE '_o_', -- true
    'bar' LIKE 'b_'; -- false

-- ILIKE
-- case insensitive
-- The BAR% pattern matches any string that begins with BAR, Bar, BaR, etc.
SELECT
	first_name,
	last_name
FROM
	customer
WHERE
	first_name ILIKE 'BAR%';

SELECT * 
FROM customer_survey 
WHERE feedback ILIKE '%pop%' 
ORDER BY 1;

--------------------------------------------
/* Text Search */
-- https://www.postgresql.org/docs/15/functions-textsearch.html

-- to_tsvector
-- tokenize 
SELECT feedback, 
to_tsvector('english', feedback) AS tsvectorized_feedback
FROM customer_survey; -- rows of "'fast':10 'high':2 'lemon':5 'recommend':3 'scooter':6"

-- combine tsvectors
SELECT rating, feedback,
to_tsvector('english', feedback) || to_tsvector('english', rating::text) 
AS searchable
FROM customer_survey;

-- tsquery
-- transforming a search query into a type for searches:
SELECT to_tsquery('english', 'lemon & scooter'); -- "'lemon' & 'scooter'"

-- plainto_tsquery
SELECT plainto_tsquery('english', 'lemon scooter'); -- "'lemon' & 'scooter'"

-- query operators
SELECT plainto_tsquery('english', 'lemon') && 
plainto_tsquery('english', 'scooter') || 
plainto_tsquery('english', 'chi'); --"'lemon' & 'scooter' | 'chi'"

-- query ts_vector object using a ts_query object 
-- using the @@ operator:
SELECT * 
FROM customer_survey
WHERE to_tsvector('english', feedback) 
    @@ plainto_tsquery('english', 'lemon scooter');

-- Generalized Inverted Index (GIN)
CREATE INDEX idx_customer_survey_search_searchable
ON customer_survey_search
USING GIN(searchable);


--------------------------------------------
--------------------------------------------
/* Examples */

-- 1 ***************************************
-- Entries in JSON format.
CREATE MATERIALIZED VIEW 
customer_search AS (
    SELECT customer_json -> 'customer_id' 
    AS customer_id, customer_json,
    to_tsvector('english', customer_json) 
    AS search_vector
    FROM customer_sales);

-- Create the GIN index on the view
CREATE INDEX customer_search_gin_idx
ON customer_search
USING GIN(search_vector);

-- Find a customer by the name of Danny who purchased the Bat scooter:
SELECT customer_id, customer_json
FROM customer_search
WHERE search_vector @@ plainto_tsquery('english', 'Danny Bat');


-- 2 ***************************************
-- Step 1:
SELECT DISTINCT p1.model, p2.model
FROM products p1 
CROSS JOIN products p2 
WHERE p1.product_type = 'scooter' 
AND p2.product_type = 'automobile'
AND p1.model NOT ILIKE '%Limited Edition%';

-- Transform the output into the query
-- Step 2:
SELECT DISTINCT
plainto_tsquery('english', p1.model) && 
plainto_tsquery('english', p2.model) 
FROM products p1 
CROSS JOIN products p2
WHERE p1.product_type = 'scooter' 
AND p2.product_type = 'automobile' 
AND p1.model NOT ILIKE '%Limited Edition%';

-- Query our database using each of these tsquery objects, and count the occurrences for each object
-- Step 3:
SELECT
sub.query,
    (SELECT COUNT(1)
    FROM customer_search
    WHERE customer_search.search_vector
    @@ sub.query)
FROM (
    SELECT DISTINCT
    plainto_tsquery('english', p1.model) && 
    plainto_tsquery('english', p2.model) AS query
    FROM products p1
    CROSS JOIN products p2
    WHERE p1.product_type = 'scooter' 
        AND p2.product_type = 'automobile'
        AND p1.model NOT ILIKE '%Limited Edition%') AS sub
ORDER BY 2 DESC;

-- 3 ***************************************
-- Text analytics example
DROP TABLE IF EXISTS body_table;
CREATE TABLE body_table (body text);

SELECT * FROM body_table;

SELECT UNNEST(STRING_TO_ARRAY(
TRIM(REGEXP_REPLACE(body,'[^a-zA-Z]+',' ','g'))
,' ')) AS word
INTO TEMP TABLE wordlist
FROM body_table;

SELECT * FROM wordlist;

SELECT *, ROW_NUMBER() OVER () AS position INTO TABLE text FROM wordlist;

SELECT * FROM text;

SELECT 	LAG(word,2) OVER w AS w1,
		LAG(word,1) OVER w AS w2,
		word AS w3,
		LEAD(word,1) OVER w AS w4,
		Lead(word,2) OVER w AS w5
		FROM text
		WINDOW w AS (ORDER BY position);
		
SELECT w1,w2,w3,w4,w5, COUNT(*) AS count FROM(
SELECT 	word AS w1,
		LEAD(word,1) OVER w AS w2,
		LEAD(word,2) OVER w AS w3,
		LEAD(word,3) OVER w AS w4,
		LEAD(word,4) OVER w AS w5
		FROM text
		WINDOW w AS (ORDER BY position)
) AS sequences
GROUP BY w1,w2,w3,w4,w5
ORDER BY count DESC;

SELECT w1,w2,w3, COUNT(*) AS count FROM(
SELECT 	word AS w1,
		LEAD(word,1) OVER w AS w2,
		LEAD(word,2) OVER w AS w3
		FROM text
		WINDOW w AS (ORDER BY position)
) AS sequences
GROUP BY w1,w2,w3
ORDER BY count DESC;

SELECT DISTINCT w1,w2,w3,w4,w5 FROM(
SELECT 	word AS w1,
		LEAD(word,1) OVER w AS w2,
		LEAD(word,2) OVER w AS w3,
		LEAD(word,3) OVER w AS w4,
		LEAD(word,4) OVER w AS w5
		FROM text
		WINDOW w AS (ORDER BY position)
) AS sequences
ORDER BY w1 DESC,w2 DESC,w3 DESC,w4 DESC,w5 DESC;

SELECT w1,w2,w3, COUNT(*) AS count FROM(
SELECT 	word AS w1,
		LEAD(word,1) OVER w AS w2,
		LEAD(word,2) OVER w AS w3
		FROM text
		WINDOW w AS (ORDER BY position)
) AS sequences
GROUP BY w1,w2,w3
HAVING w1='of' AND w2='the'
ORDER BY count DESC;

SELECT w1,w2,w3,w4, COUNT(*) AS count FROM(
SELECT 	word AS w1,
		LEAD(word,1) OVER w AS w2,
		LEAD(word,2) OVER w AS w3,
		LEAD(word,3) OVER w AS w4
		FROM text
		WINDOW w AS (ORDER BY position)
) AS sequences
GROUP BY w1,w2,w3,w4
HAVING w1='out' AND w2='of' AND w3='the'
ORDER BY count DESC;

