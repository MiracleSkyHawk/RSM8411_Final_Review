--------------------------------------------
/* Latitude and Longitude */

-- Latitude
-- +90° latitude --> the North Pole
-- 0° latitude --> the equator
-- -90° latitude --> the South Pole

-- Longitude
-- 0° latitude --> Greenwich, England
-- west (-) 
-- east (+) 
-- range: -180° west to +180° east

--------------------------------------------
/* Packages */

-- Installing packages
CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;


--------------------------------------------
/* Calculations */

-- Define points
SELECT point(longitude, latitude)
FROM customers; --"(-90.2625,38.5814)"

-- Distance in miles
SELECT point(-90, 38) <@> point(-91, 37) 
AS distance_in_miles; -- 88.19493383797524

-- Distance in km
SELECT 
(point(-90, 38) <@> point(-91, 37)) * 1.609344 
AS distance_in_kms;


--------------------------------------------
--------------------------------------------
/* Examples */
CREATE TEMP TABLE customer_points AS(
    SELECT customer_id,
    point(longitude, latitude) AS lng_lat_point
    FROM customers
    WHERE longitude IS NOT NULL
    AND latitude IS NOT NULL
    );

CREATE TEMP TABLE dealership_points AS (
    SELECT
    dealership_id, 
    point(longitude, latitude) AS lng_lat_point
    FROM dealerships
    );

CREATE TEMP TABLE customer_dealership_distance AS (    
    SELECT customer_id, dealership_id,
    c.lng_lat_point <@> d.lng_lat_point AS distance 
    FROM customer_points c 
    CROSS JOIN dealership_points d
    );

CREATE TEMP TABLE closest_dealerships AS (
    SELECT DISTINCT ON (customer_id) 
    customer_id, dealership_id, distance 
    FROM customer_dealership_distance
    ORDER BY customer_id, distance
    );

SELECT AVG(distance) AS avg_dist,
PERCENTILE_CONT(0.5) 
WITHIN GROUP 
(ORDER BY distance) AS median_dist
FROM closest_dealerships;