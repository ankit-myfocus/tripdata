-- DATABASE: tripdata_2013


-- TABLES: tripdata , trip_data , ride_data , rides_data_ , rides_data_subscriber , rides_data_subscriber

-- 1. tripdata - Original unedited table containing raw trip data.

-- 2. trip_data - Modified data types and cleaned version of the original tripdata.

-- 3. rides_data - Cleaned, sorted, and further refined data for analysis. Key changes:
--           	   Sorted by starttime.
--                 Removed carriage return (\r) characters from the birthyear column.
-- 	    	       Converted blank values in the birthyear column to NULL.
--  	           Modified birthyear column to YEAR datatype.
--       	       Updated blank values in the gender column to NULL.
--                 Modified gender datatype to ENUM for memory efficiency.
--                 Checked for NULL and duplicate values in all key columns.
--         	       Calculated average and maximum ride lengths for the overall data, as well as separately for customers and subscribers.
--                 Calculated the mode of tripduration for overall data, customers, and subscribers.
--
-- 4. rides_data_ - Extended version of rides_data with an additional dayofweek column. Key analyses:
--                  Counted the number of rides by day of the week, sorted from Monday to Sunday.
-- 				    Analyzed monthly ridership patterns to identify peak and low periods.
 
-- 5. rides_data_subscriber - Data for subscribers extracted from rides_data_. Key analyses:
--                            Counted the number of rides by day of the week for subscribers.
--                            Identified peak ridership hours and months for subscribers.

-- 6. rides_data_customer - Data for customers extracted from rides_data_. Key analyses:
--                          Counted the number of rides by day of the week for customers.
--                          Identified peak ridership hours and months for customers.


-- Creating the database to store 2013 trip data
CREATE DATABASE tripdata_2013;

-- Creating the `tripdata` table with necessary columns representing trip details
CREATE TABLE tripdata (
    trip_id MEDIUMINT UNSIGNED NOT NULL,
    starttime VARCHAR(30) NOT NULL,
    stoptime VARCHAR(30) NOT NULL,
    bikeid MEDIUMINT UNSIGNED NOT NULL,
    tripduration MEDIUMINT UNSIGNED NOT NULL,
    from_station_id SMALLINT UNSIGNED NOT NULL,
    from_station_name VARCHAR(50) NOT NULL,
    to_station_id SMALLINT UNSIGNED NOT NULL,
    to_station_name VARCHAR(50) NOT NULL,
    usertype ENUM('Subscriber', 'Customer') NOT NULL,
    gender VARCHAR(6),
    birthyear VARCHAR(5)
);

-- Disable SQL safe update mode to allow unrestricted updates and deletions
SET SQL_SAFE_UPDATES = 0;

-- Check MySQL server directory for file reading and writing privileges
SELECT @@secure_file_priv;

-- Importing CSV data into the `tripdata` table, specifying delimiters and ignoring the header
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Divvy_Trips_2013.csv'
INTO TABLE tripdata 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- Creating a copy of the `tripdata` table to avoid altering original data
CREATE TABLE trip_data AS SELECT * FROM tripdata;

-- Checking the structure of the `trip_data` table to view column data types
DESCRIBE trip_data;

-- Modifying the `starttime` and `stoptime` columns to the `DATETIME` datatype
ALTER TABLE trip_data 
MODIFY COLUMN starttime DATETIME, 
MODIFY COLUMN stoptime DATETIME;

-- Creating the `rides_data` table, sorted by `starttime` for chronological analysis
CREATE TABLE rides_data AS 
SELECT * FROM trip_data 
ORDER BY starttime;

-- Checking for the length of `birthyear` to ensure proper formatting (no \r)
SELECT LENGTH(birthyear), COUNT(LENGTH(birthyear)) 
FROM rides_data 
GROUP BY LENGTH(birthyear) 
ORDER BY LENGTH(birthyear);

-- Removing trailing \r characters from the `birthyear` values
UPDATE rides_data 
SET birthyear = TRIM(TRAILING '\r' FROM birthyear);

-- Verifying the distinct lengths of `birthyear` after cleaning
SELECT DISTINCT(LENGTH(birthyear)) FROM rides_data;

-- Converting blank `birthyear` values to `NULL`
UPDATE rides_data 
SET birthyear = NULL 
WHERE LENGTH(birthyear) = 0;

-- Modifying the `birthyear` column to the `YEAR` datatype
ALTER TABLE rides_data 
MODIFY birthyear YEAR;

-- Retrieving distinct values of the `gender` column for validation
SELECT DISTINCT(gender) FROM rides_data;

-- Converting blank `gender` values to `NULL`
UPDATE rides_data 
SET gender = NULL 
WHERE gender = '';

-- Modifying the `gender` column to `ENUM('Male', 'Female')` for memory efficiency
ALTER TABLE rides_data 
MODIFY COLUMN gender ENUM('Male', 'Female') NULL;

-- Checking for duplicate `trip_id` entries
SELECT COUNT(DISTINCT(trip_id)) AS count_of_trip_id, COUNT(*) AS row_count_ 
FROM rides_data;

-- Checking for `NULL` or invalid values in key columns
SELECT * 
FROM rides_data 
WHERE trip_id IS NULL 
OR starttime IS NULL 
OR stoptime IS NULL 
OR bikeid IS NULL 
OR tripduration IS NULL 
OR from_station_id IS NULL 
OR from_station_name IS NULL 
OR from_station_name = '' 
OR to_station_id IS NULL 
OR to_station_name IS NULL 
OR to_station_name = '' 
OR usertype IS NULL 
OR usertype = '';

-- Calculating average ride lengths for overall data, customers, and subscribers
SELECT 
    AVG(tripduration) AS overall_avg_ride_length,
    AVG(CASE WHEN usertype = 'Customer' THEN tripduration END) AS customer_avg_ride_length,
    AVG(CASE WHEN usertype = 'Subscriber' THEN tripduration END) AS subscriber_avg_ride_length
FROM rides_data;

-- Calculating maximum ride lengths for overall data, customers, and subscribers
SELECT 
    MAX(tripduration) AS overall_max_ride_length,
    MAX(CASE WHEN usertype = 'Customer' THEN tripduration END) AS customer_max_ride_length,
    MAX(CASE WHEN usertype = 'Subscriber' THEN tripduration END) AS subscriber_max_ride_length
FROM rides_data;

-- Calculating mode (most frequent value) of `tripduration`
WITH Mode_Calc AS (
    SELECT tripduration, COUNT(*) AS freq
    FROM rides_data
    GROUP BY tripduration
),
Overall_Mode AS (
    SELECT tripduration AS overall_mode_ride_length
    FROM Mode_Calc
    GROUP BY tripduration
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT 
    AVG(tripduration) AS overall_avg_ride_length,
    (SELECT overall_mode_ride_length FROM Overall_Mode) AS overall_mode_ride_length
FROM rides_data;

-- Calculating mode of `tripduration` for customers and subscribers
WITH Mode_Calc AS (
    SELECT tripduration, usertype, COUNT(*) AS freq
    FROM rides_data
    GROUP BY tripduration, usertype
),
Customer_Mode AS (
    SELECT tripduration AS customer_mode_ride_length
    FROM Mode_Calc
    WHERE usertype = 'Customer'
    GROUP BY tripduration
    ORDER BY COUNT(*) DESC
    LIMIT 1
),
Subscriber_Mode AS (
    SELECT tripduration AS subscriber_mode_ride_length
    FROM Mode_Calc
    WHERE usertype = 'Subscriber'
    GROUP BY tripduration
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT 
    AVG(CASE WHEN usertype = 'Customer' THEN tripduration END) AS customer_avg_ride_length,
    (SELECT customer_mode_ride_length FROM Customer_Mode) AS customer_mode_ride_length,
    AVG(CASE WHEN usertype = 'Subscriber' THEN tripduration END) AS subscriber_avg_ride_length,
    (SELECT subscriber_mode_ride_length FROM Subscriber_Mode) AS subscriber_mode_ride_length
FROM rides_data;

-- Creating table `tripdata_customer` to separate customer data
CREATE TABLE tripdata_customer AS 
SELECT * 
FROM rides_data 
WHERE usertype = 'Customer';

-- Creating table `tripdata_subscriber` to separate subscriber data
CREATE TABLE tripdata_subscriber AS 
SELECT * 
FROM rides_data 
WHERE usertype = 'Subscriber';

-- Adding a `dayofweek` column to `rides_data_` to store the day of the week for each trip
CREATE TABLE rides_data_ AS 
SELECT *, DATE_FORMAT(STR_TO_DATE(starttime, '%Y-%m-%d %H:%i:%s'), '%W') AS dayofweek 
FROM rides_data;

-- Counting the number of rides by day of the week, sorted from Monday to Sunday
SELECT dayofweek, COUNT(DISTINCT(trip_id)) AS no_of_rides 
FROM rides_data_ 
GROUP BY dayofweek 
ORDER BY FIELD(dayofweek, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Creating `rides_data_customer` with the `dayofweek` column
CREATE TABLE rides_data_customer AS 
SELECT *  
FROM rides_data_ 
WHERE usertype = 'Customer';

-- Creating `rides_data_subscriber` with the `dayofweek` column
CREATE TABLE rides_data_subscriber AS 
SELECT *  
FROM rides_data_ 
WHERE usertype = 'Subscriber';


-- Counting the number of rides by day of the week for customers
SELECT dayofweek, COUNT(DISTINCT(trip_id)) AS no_of_rides 
FROM rides_data_customer 
GROUP BY dayofweek 
ORDER BY FIELD(dayofweek, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Counting the number of rides by day of the week for subscribers
SELECT dayofweek, COUNT(DISTINCT(trip_id)) AS no_of_rides 
FROM rides_data_subscriber 
GROUP BY dayofweek 
ORDER BY FIELD(dayofweek, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Identifying the peak hours for subscribers
SELECT HOUR(starttime) AS hour_of_day, COUNT(*) AS number_of_rides
FROM rides_data_subscriber
GROUP BY HOUR(starttime)
ORDER BY number_of_rides DESC;

-- Identifying the peak hours for customers
SELECT HOUR(starttime) AS hour_of_day, COUNT(*) AS number_of_rides
FROM rides_data_customer
GROUP BY HOUR(starttime)
ORDER BY number_of_rides DESC;

-- Identifying the busiest months for subscribers
SELECT MONTH(starttime) AS month, COUNT(*) AS number_of_rides
FROM rides_data_subscriber
GROUP BY MONTH(starttime)
ORDER BY number_of_rides DESC;

-- Identifying the busiest months for customers
SELECT MONTH(starttime) AS month, COUNT(*) AS number_of_rides
FROM rides_data_customer
GROUP BY MONTH(starttime)
ORDER BY number_of_rides DESC;

-- Counting the number of rides by month for subscribers, for trend analysis
SELECT MONTH(starttime) AS month, COUNT(DISTINCT(trip_id)) AS no_of_rides
FROM rides_data_subscriber
GROUP BY month
ORDER BY month;

-- Counting the number of rides by month for customers, for trend analysis
SELECT MONTH(starttime) AS month, COUNT(DISTINCT(trip_id)) AS no_of_rides
FROM rides_data_customer
GROUP BY month
ORDER BY month;

