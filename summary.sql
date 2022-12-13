--------------------------------------------
/* Create tables and views */

-- Create table
CREATE TABLE IF NOT EXISTS table_name (
    column1 datatype(length) column_contraint,
    column2 datatype(length) column_contraint,
    column3 datatype(length) column_contraint,
    table_constraints
);

-- create table example
CREATE TABLE REP
    (REP_NUM CHAR(2) PRIMARY KEY,
    LAST_NAME CHAR(15) NOT NULL,
    FIRST_NAME CHAR(15) NOT NULL,
    STREET CHAR(15),
    CITY CHAR(15),
    STATE CHAR(2),
    ZIP CHAR(5),
    COMMISSION DECIMAL(7,2),
    RATE DECIMAL(3,2) );

--Create tables with two or more primary keys
CREATE TABLE ORDER_LINE
    (ORDER_NUM CHAR(5),
    PART_NUM CHAR(4),
    NUM_ORDERED DECIMAL(3,0),
    QUOTED_PRICE DECIMAL(6,2),
    PRIMARY KEY (ORDER_NUM, PART_NUM) );

-- Create table from an existing table
CREATE TABLE LEVEL1_CUSTOMER
    (CUSTOMER_NUM CHAR (3) PRIMARY KEY,
    CUSTOMER_NAME CHAR (35),
    BALANCE DECIMAL (8,2),
    CREDIT_LIMIT DECIMAL (8,2),
    REP_NUM CHAR(2) );

INSERT INTO LEVEL1_CUSTOMER
SELECT CUSTOMER_NUM, CUSTOMER_NAME, BALANCE, CREDIT_LIMIT, REP_NUM
FROM CUSTOMER
WHERE CREDIT_LIMIT = 7500;

-- Create table from query
CREATE TABLE action_film AS
SELECT
    film_id,
    title,
    release_year,
    length,
    rating
FROM
    film
INNER JOIN film_category USING (film_id)
WHERE
    category_id = 1;

-- Constraints check and fk
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
	id SERIAL PRIMARY KEY,
    customer_id INT,
	first_name VARCHAR (50),
	last_name VARCHAR (50),
	birth_date DATE CHECK (birth_date > '1900-01-01'),
	joined_date DATE CHECK (joined_date > birth_date),
	salary numeric CHECK(salary > 0)
    CONSTRAINT fk_customer
      FOREIGN KEY(customer_id) 
	  REFERENCES customers(customer_id)
);

-- Create and drop temporary  tables
CREATE TEMP TABLE customers(
    customer_id INT
);

DROP TABLE customers;

-- Create Views with original column names
CREATE VIEW HOUSEWARES AS 
SELECT PART_NUM, DESCRIPTION, ON_HAND, PRICE
FROM PART
WHERE CLASS = 'HW';

-- Create Views with new column names
CREATE VIEW HOUSEWARES (PNUM, DSC, OH, PRCE) AS 
SELECT PART_NUM, DESCRIPTION, ON_HAND, PRICE
FROM PART
WHERE CLASS = 'HW';

-- Drop views
DROP VIEW film_master CASCADE;

-- Create MATERIALIZED VIEW
CREATE MATERIALIZED VIEW view_name
AS
query
WITH [NO] DATA;

REFRESH MATERIALIZED VIEW view_name;


--------------------------------------------
/* Updating */

-- Update values
UPDATE REP
SET LAST_NAME = 'Perry'
WHERE REP_NUM = '85';


-- Update multiple columns
UPDATE table_name
SET "column1" = value1, "column2" = value2, "columnN" = valueN
WHERE condition;

-- Change a value to NULL
UPDATE LEVEL1_CUSTOMER
SET BALANCE = NULL
WHERE CUSTOMER_NUM = '725';

-- Insert values
INSERT INTO ORDERS
VALUES
    ('21608','20-OCT-2010','148'),
    ('21610','20-OCT-2010','356'),
    ('21613','21-OCT-2010','408'),
    ('21614','21-OCT-2010','282'),
    ('21617','23-OCT-2010','608'),
    ('21619','23-OCT-2010','148'),
    ('21623','23-OCT-2010','608');


-- Delete rows
DELETE FROM LEVEL1_CUSTOMER
WHERE CUSTOMER_NUM = '895';

--------------------------------------------
/* Altering */

-- Alter table to add columns
ALTER TABLE table_name
    ADD COLUMN column_name1 data_type constraint,
    ADD COLUMN column_name2 data_type constraint,
    ADD COLUMN column_namen data_type constraint;

-- example of Alter table to add columns
ALTER TABLE LEVEL1_CUSTOMER
    ADD CUSTOMER_TYPE CHAR(1);

-- Change null or not null constraint
ALTER TABLE LEVEL1_CUSTOMER
ALTER CREDIT_LIMIT SET NOT NULL;

-- Add foreign key
ALTER TABLE ORDERS
ADD FOREIGN KEY (CUSTOMER_NUM) 
    REFERENCES CUSTOMER;

-- Add foreign key when creating tables
-- No action. For other types: https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-foreign-key/
CREATE TABLE contacts(
   contact_id INT GENERATED ALWAYS AS IDENTITY,
   customer_id INT,
   contact_name VARCHAR(255) NOT NULL,
   phone VARCHAR(15),
   email VARCHAR(100),
   PRIMARY KEY(contact_id),
   CONSTRAINT fk_customer
        FOREIGN KEY(customer_id) 
        REFERENCES customers(customer_id)
);

-- Add checks
ALTER TABLE PARTADD CHECK (CLASS IN ('AP', 'HW', SG));


--------------------------------------------
/* Drop Tables */

-- Drop a table
DROP TABLE IF EXISTS authors;

-- Drop a table with all dependent objects
DROP TABLE authors CASCADE;

--------------------------------------------
/* Drop Coumns */

-- Drop multiple columns
ALTER TABLE table_name
    DROP COLUMN column_name1,
    DROP COLUMN column_name2;

-- Example of dropping multiple columns
ALTER TABLE books 
    DROP COLUMN isbn,
    DROP COLUMN description;

--------------------------------------------
/* Creating an index */

-- Index on one column
CREATE INDEX BALIND ON CUSTOMER(BALANCE);

-- Index on many columns
CREATE INDEX REPNAME ON REP(LAST_NAME, FIRST_NAME)

-- Delete index
DROP INDEX index_name, index_name2;

-- Unique index
CREATE UNIQUE INDEX idx_employees_mobile_phone
ON employees(mobile_phone);


--------------------------------------------
/* Compound conditions */

-- AND, OR, NOT, BETWEEN, IS NULL
-- AND
SELECT DESCRIPTION
FROM PART
WHERE WAREHOUSE = '3'
AND ON_HAND > 25;

-- NOT
SELECT DESCRIPTION
FROM PART
WHERE NOT (WAREHOUSE = '3');

-- BETWEEN
-- BETWEEN equals to value >= low and value <= high
SELECT CUSTOMER_NUM, CUSTOMER_NAME, BALANCE
FROM CUSTOMER
WHERE BALANCE BETWEEN 2000 AND 5000;

-- IS NULL
SELECT CUSTOMER_NUM, CUSTOMER_NAME
FROM CUSTOMER
WHERE STREET IS NULL;

--------------------------------------------
/* operators */

-- LIKE operator
SELECT CUSTOMER_NUM, CUSTOMER_NAME, STREET
FROM CUSTOMER
WHERE STREET LIKE '%Central%';

-- IN operator
SELECT CUSTOMER_NUM, CUSTOMER_NAME, CREDIT_LIMIT
FROM CUSTOMER
WHERE CREDIT_LIMIT IN (5000, 10000, 15000);

-- Sorting
-- Ascending is default sort order
SELECT CUSTOMER_NUM, CUSTOMER_NAME, CREDIT_LIMIT
FROM CUSTOMER
ORDER BY CREDIT_LIMIT DESC, CUSTOMER_NAME;

-- DISTINCT operator
SELECT DISTINCT(CUSTOMER_NUM)
FROM ORDERS;

-- GROUP BY clause
-- PostgreSQL evaluation order
-- FROM --> WHERE --> GROUP BY --> HAVING --> SELECT 
-- DISTINCT --> ORDER BY --> LIMIT
SELECT CREDIT_LIMIT, COUNT(*)
FROM CUSTOMER
WHERE REP_NUM = '20'
GROUP BY CREDIT_LIMIT
HAVING COUNT(*) > 1
ORDER BY CREDIT_LIMIT;

-- EXISTS operator
SELECT ORDER_NUM, ORDER_DATE
FROM ORDERS
WHERE EXISTS
    (SELECT *
    FROM ORDER_LINE
    WHERE ORDERS.ORDER_NUM = ORDER_LINE.ORDER_NUM
    AND PART_NUM = 'DR93');

-- Assignment operator
stock_qty := get_stock(NEW.product_code)

--------------------------------------------
/* JOINS */

-- SELF JOIN
SELECT F.CUSTOMER_NUM, F.CUSTOMER_NAME, S.CUSTOMER_NUM,
    S.CUSTOMER_NAME, F.CITY
FROM CUSTOMER F, CUSTOMER S
WHERE F.CITY = S.CITY
AND F.CUSTOMER_NUM < S.CUSTOMER_NUM
ORDER BY F.CUSTOMER_NUM, S.CUSTOMER_NUM;

-- Joining several tables
SELECT PART_NUM, NUM_ORDERED, ORDER_LINE.ORDER_NUM, ORDER_DATE, 
CUSTOMER.CUSTOMER_NUM, CUSTOMER_NAME, LAST_NAME
FROM ORDER_LINE, ORDERS, CUSTOMER, REP
WHERE ORDERS.ORDER_NUM = ORDER_LINE.ORDER_NUM
AND CUSTOMER.CUSTOMER_NUM = ORDERS.CUSTOMER_NUM
AND REP.REP_NUM = CUSTOMER.REP_NUM;

-- UNION operation
-- every row that is in either the first table, the second table, or both tables
SELECT CUSTOMER_NUM, CUSTOMER_NAME
FROM CUSTOMER
WHERE REP_NUM = '65'
UNION
SELECT CUSTOMER.CUSTOMER_NUM, CUSTOMER_NAME
FROM CUSTOMER, ORDERS
WHERE CUSTOMER.CUSTOMER_NUM = ORDERS.CUSTOMER_NUM;

-- INTERSECT operation
-- all rows that are in both tables
SELECT CUSTOMER_NUM, CUSTOMER_NAME
FROM CUSTOMER
WHERE REP_NUM = '65'
INTERSECT
SELECT CUSTOMER.CUSTOMER_NUM, CUSTOMER_NAME
FROM CUSTOMER, ORDERS
WHERE CUSTOMER.CUSTOMER_NUM = ORDERS.CUSTOMER_NUM;

-- MINUS operation
SELECT CUSTOMER_NUM, CUSTOMER_NAME
FROM CUSTOMER
WHERE REP_NUM = '65'
MINUS
SELECT CUSTOMER.CUSTOMER_NUM, CUSTOMER_NAME
FROM CUSTOMER, ORDERS
WHERE CUSTOMER.CUSTOMER_NUM = ORDERS.CUSTOMER_NUM;

-- INNER JOIN
SELECT CUSTOMER.CUSTOMER_NUM, CUSTOMER_NAME, ORDER_NUM, ORDER_DATE
FROM CUSTOMER
INNER JOIN ORDERS
ON CUSTOMER.CUSTOMER_NUM = ORDERS.CUSTOMER_NUM
ORDER BY CUSTOMER.CUSTOMER_NUM;

-- LEFT JOIN
SELECT CUSTOMER.CUSTOMER_NUM, CUSTOMER_NAME
ORDER_NUM, ORDER_DATE
FROM CUSTOMER
LEFT JOIN ORDERS
ON CUSTOMER.CUSTOMER_NUM = ORDERS.CUSTOMER_NUM
ORDER BY CUSTOMER.CUSTOMER_NUM;

-- FULL ORDER JOIN 
SELECT
    employee_name,
	department_name
FROM
	employees e
FULL OUTER JOIN departments d 
        ON d.department_id = e.department_id;

-- CROSS JOIN
SELECT select_list
FROM T1
CROSS JOIN T2;

--------------------------------------------
/* Case */

-- Example 1
SELECT title,
        length,
        CASE
            WHEN length> 0
                AND length <= 50 THEN 'Short'
            WHEN length > 50
                AND length <= 120 THEN 'Medium'
            WHEN length> 120 THEN 'Long'
        END duration
FROM film
ORDER BY title;

-- Example 2
SELECT
	SUM (CASE
            WHEN rental_rate = 0.99 THEN 1
	        ELSE 0
        END
	) AS "Economy",
	SUM (
		CASE
            WHEN rental_rate = 2.99 THEN 1
            ELSE 0
		END
	) AS "Mass",
	SUM (
		CASE
            WHEN rental_rate = 4.99 THEN 1
            ELSE 0
		END
	) AS "Premium"
FROM
	film;


--------------------------------------------
/* COALESCE */
COALESCE (argument_1, argument_2, …);

UPDATE cstr_prd_bb_srv SET
    srv_INT_fl=COALESCE(srv_INT_fl,0), 
    srv_TV_fl=COALESCE(srv_TV_fl,0),
    srv_Phone_fl=COALESCE(srv_Phone_fl,0), 
    srv_Mobile_fl=COALESCE(srv_Mobile_fl,0);

--------------------------------------------
/* Common Table Expression (CTE) */

WITH d AS 
    (SELECT * FROM dealerships
    WHERE dealerships.state = 'CA')
SELECT *
FROM salespeople
INNER JOIN d ON d.dealership_id = salespeople.dealership_id
ORDER BY 1;

-- This equals to 
SELECT *
FROM salespeople
INNER JOIN (
SELECT * FROM dealerships
WHERE dealerships.state = 'CA') d
ON d.dealership_id = 
salespeople.dealership_id
ORDER BY 1;

--------------------------------------------
/* Least function*/

SELECT LEAST( 5, 2, 9 ); -- returns 2

--------------------------------------------
/* Casting */

SELECT product_id, model, year::TEXT, product_type
FROM products;

--------------------------------------------
/* Distinct and Distinct on */

-- Distinct 
SELECT
   DISTINCT column1, column2
FROM
   table_name;

-- Distinct on
SELECT
   DISTINCT ON (column1) column_alias,
   column2
FROM
   table_name
ORDER BY
   column1,
   column2;

--------------------------------------------
/* Triggers */

-- Trigger template
CREATE TRIGGER some_trigger_name 
{ BEFORE | AFTER | INSTEAD OF } 
{ INSERT | DELETE | UPDATE | TRUNCATE } 
ON table_name
FOR EACH { ROW | STATEMENT }
EXECUTE PROCEDURE function_name
(function_arguments);

-- Lecture example
CREATE FUNCTION update_stock() 
RETURNS TRIGGER AS 
    $stock_trigger$
        DECLARE
        stock_qty integer;
            BEGIN
                stock_qty := get_stock(NEW.product_code) - NEW.qty;

                UPDATE products SET stock=stock_qty
                WHERE product_code=NEW.product_code;
                RETURN NEW;
            END; 
    $stock_trigger$
LANGUAGE PLPGSQL;

CREATE TRIGGER update_trigger
AFTER INSERT ON order_info
FOR EACH ROW
EXECUTE PROCEDURE update_stock();

-- Exercise example
CREATE FUNCTION avg_qty() 
RETURNS TRIGGER AS 
    $_avg$
        DECLARE _avg double precision;
            BEGIN
                SELECT AVG(qty) INTO _avg 
                FROM order_info;

                INSERT INTO avg_qty_log (order_id, avg_qty) 
                    VALUES (NEW.order_id, _avg);
                RETURN NEW;
            END; 
    $_avg$
LANGUAGE PLPGSQL;

CREATE TRIGGER avg_trigger
AFTER INSERT ON order_info
FOR EACH ROW
EXECUTE PROCEDURE avg_qty();

--------------------------------------------
/* Functions */

-- Simple function example
CREATE FUNCTION fixed_val() 
RETURNS integer AS 
    $$
        BEGIN
            RETURN 1;
        END; 
    $$
LANGUAGE PLPGSQL;

SELECT * FROM fixed_val();

-- Functions without Arguments
CREATE FUNCTION num_samples() 
RETURNS integer AS 
    $total$
        DECLARE total integer;
            BEGIN
                SELECT COUNT(*) INTO total FROM sales;
                RETURN total;
            END; 
    $total$
LANGUAGE PLPGSQL;

SELECT num_samples();

-- Functions with Arguments
CREATE FUNCTION avg_sales(channel_type TEXT) 
RETURNS double precision AS 
    $channel_avg$
        DECLARE channel_avg double precision;
            BEGIN
                SELECT AVG(sales_amount) INTO channel_avg 
                FROM sales 
                WHERE channel=channel_type;
                RETURN channel_avg;
            END; 
    $channel_avg$
LANGUAGE PLPGSQL;

SELECT avg_sales('dealership');

-- Functions with multiple Arguments
CREATE FUNCTION avg_sales_window (from_date DATE, to_date DATE)
RETURNS DOUBLE PRECISION AS
    $sales_avg$
        DECLARE sales_avg DOUBLE PRECISION;
            BEGIN
                SELECT AVG(sales_amount) 
                FROM sales
                INTO sales_avg
                WHERE sales_transaction_date >= from_date
                AND sales_transaction_date <= to_date;
                RETURN sales_avg;
            END;
    $sales_avg$
LANGUAGE PLPGSQL;

SELECT avg_sales_window('2013-04-12', '2014-04-12');

-- Drop functions
DROP FUNCTION update_stock();

--------------------------------------------
/* Procedures */

-- Example 1
CREATE OR REPLACE PROCEDURE add_new_part(
	new_part_name varchar,
	new_vendor_name varchar
) AS 
    $$
        DECLARE
            v_part_id INT;
            v_vendor_id INT;
        BEGIN
            -- insert into the parts table
            INSERT INTO parts(part_name) 
            VALUES(new_part_name) 
            RETURNING part_id INTO v_part_id;
            
            -- insert a new vendor
            INSERT INTO vendors(vendor_name)
            VALUES(new_vendor_name)
            RETURNING vendor_id INTO v_vendor_id;
            
            -- insert into vendor_parts
            INSERT INTO vendor_parts(part_id, vendor_id)
            VALUEs(v_part_id,v_vendor_id);
            
        END;
    $$
LANGUAGE PLPGSQL;

-- Example 2 call procedure
create or replace procedure transfer(
   sender int,
   receiver int, 
   amount dec
) as 
    $$
        begin
            -- subtracting the amount from the sender's account 
            update accounts 
            set balance = balance - amount 
            where id = sender;

            -- adding the amount to the receiver's account
            update accounts 
            set balance = balance + amount 
            where id = receiver;

            commit;
        end;
    $$
language plpgsql;

call transfer(1,2,1000);

-- Lecture example
CREATE OR REPLACE PROCEDURE add_cat() AS
	$$
		BEGIN
			WITH avg_price AS 
				(SELECT product_type, AVG(base_msrp) AS avg_p 
				FROM d_products
				GROUP BY product_type)
			UPDATE d_products SET cat=
				(CASE WHEN base_msrp>(SELECT 1.1*avg_p FROM avg_price WHERE d_products.product_type=avg_price.product_type)
					THEN 'high'
					WHEN base_msrp<0.9*(SELECT avg_p FROM avg_price WHERE d_products.product_type=avg_price.product_type)
					THEN 'low'
					ELSE 'regular'
                    END);
		END;
	$$
LANGUAGE PLPGSQL;

CALL add_cat();

--------------------------------------------
/* IF statement */

-- PL/pgSQL if-then-else statement
do $$
declare
    selected_film film%rowtype;
    input_film_id film.film_id%type := 100;
begin  

    select * from film
    into selected_film
    where film_id = input_film_id;
  
    if not found then
        raise notice 'The film % could not be found', 
	        input_film_id;
    else
        raise notice 'The film title is %', selected_film.title;
    end if;
end $$

-- PL/pgSQL if-then-elsif Statement
do $$
declare
    v_film film%rowtype;
    len_description varchar(100);
begin  

    select * from film
    into v_film
    where film_id = 100;
    
    if not found then
        raise notice 'Film not found';
    else
        if v_film.length >0 and v_film.length <= 50 then
            len_description := 'Short';
        elsif v_film.length > 50 and v_film.length < 120 then
            len_description := 'Medium';
        elsif v_film.length > 120 then
            len_description := 'Long';
        else 
            len_description := 'N/A';
        end if;
        
        raise notice 'The % film is %.',
            v_film.title,  
            len_description;
    end if;
end $$

-- Example in a function
create or replace function fn_check_time_punch() 
returns trigger as 
    $psql$
        begin
            if new.is_out_punch = (
                select tps.is_out_punch
                from time_punch tps
                where tps.employee_id = new.employee_id
                order by tps.id desc limit 1
            ) then
                return null;
            end if;
            return new;
        end;
    $psql$ 
language plpgsql;

--------------------------------------------
/* Window Functions */

-- Basic syntax
SELECT {columns},
{window_func} OVER (PARTITION BY 
    {partition_key} ORDER BY {order_key} 
    {range_rows_groups} BETWEEN 
    {frame_start} AND {frame_end})
FROM {table1};

window_function(arg1, arg2,..) OVER (
    [PARTITION BY partition_expression]
    [ORDER BY sort_expression [ASC | DESC] [NULLS {FIRST | LAST }]])  

-- Shortened form
SELECT
    wf1() OVER(PARTITION BY c1 ORDER BY c2),
    wf2() OVER(PARTITION BY c1 ORDER BY c2)
FROM table_name;

SELECT 
    wf1() OVER w,
    wf2() OVER w,
FROM table_name
WINDOW w AS (PARTITION BY c1 ORDER BY c2)
ORDER BY col_name0;

-- PARTITION Example: Count how many rows for each gender. Counts are the same
SELECT customer_id, title, first_name, last_name, gender,
COUNT(*) OVER (PARTITION BY gender) as total_customers
FROM customers
ORDER BY customer_id;

-- ORDER Example: Create index by customer-id order
SELECT customer_id, title, first_name, last_name, gender,
COUNT(*) OVER (ORDER BY customer_id) as total_customers
FROM customers
ORDER BY customer_id;

-- PARTITION & ORDER Example
SELECT customer_id, title, first_name, last_name, gender,
COUNT(*) OVER (PARTITION BY gender ORDER BY customer_id) AS total_customers
FROM customers
ORDER BY customer_id;

-- Lag function
SELECT
	year, 
	amount,
	group_id,
	LAG(amount,1) OVER (
		PARTITION BY group_id
		ORDER BY year
	) previous_year_sales
FROM
	sales;

-- RANK 
SELECT *, RANK() OVER 
    (PARTITION BY dealership_id ORDER BY hire_date DESC)
FROM salespeople
WHERE termination_date IS NULL;

-- Moving sales average example
WITH daily_sales AS (
    SELECT sales_transaction_date::DATE,
    SUM(sales_amount) AS total_sales
    FROM sales
    GROUP BY 1
),
moving_average_calculation_7 AS (
    SELECT sales_transaction_date, total_sales,
    AVG(total_sales) OVER (
        ORDER BY sales_transaction_date 
        ROWS BETWEEN 6 PRECEDING and CURRENT ROW) 
        AS sales_moving_average_7,
    ROW_NUMBER() OVER (
        ORDER BY sales_transaction_date) 
        AS row_number
    FROM daily_sales
    ORDER BY 1)
SELECT sales_transaction_date, row_number,
CASE WHEN 
    row_number>=7 THEN sales_moving_average_7 
    ELSE NULL 
    END
AS sales_moving_average_7
FROM moving_average_calculation_7;

-- Sales target example
WITH daily_sales as (
    SELECT sales_transaction_date::DATE,
    SUM(sales_amount) as total_sales
    FROM sales
    GROUP BY 1
),
sales_stats_30 AS (
    SELECT sales_transaction_date, 
    total_sales,
    MAX(total_sales) OVER (
        ORDER BY sales_transaction_date ROWS 
        BETWEEN 30 PRECEDING and 1 PRECEDING)
    AS max_sales_30
    FROM daily_sales
    ORDER BY 1)
SELECT sales_transaction_date, total_sales, max_sales_30
FROM sales_stats_30
WHERE sales_transaction_date>='2019-01-01';

--------------------------------------------
/* Date Table */

-- Date template
SELECT day::date 
FROM generate_series('2010-03-10'::timestamp, '2019-05-31', '1 day') AS day;

--------------------------------------------
/* Querying JSON data */

-- Insert JSON
INSERT INTO orders (info)
VALUES('{ "customer": "John Doe", "items": {"product": "Beer","qty": 6}}');

-- get all customers in form of JSON
SELECT info -> 'customer' AS customer
FROM orders;

-- get all customers in form of text
SELECT info ->> 'customer' AS customer
FROM orders;

-- chain
SELECT info -> 'items' ->> 'product' as product
FROM orders
ORDER BY product;

--------------------------------------------
/* Date related*/

-- date_trunc
date_trunc('datepart', field)

EXTRACT(YEAR FROM datetime_)