# tripdata
SQL Queries for my tripdata project

TripData is a comprehensive data analysis project that aims to explore, analyze, and visualize trip-related data. This project helps in understanding patterns, trends, and insights from trip data to enhance decision-making for transportation and travel services.


### 1. **Data Collection**
   - **Creating Database and Tables**:
     - `CREATE DATABASE tripdata_2013;`
     - `CREATE TABLE tripdata (...)`: Initial table creation to store the raw trip data.
   - **Loading Data**:
     - `LOAD DATA INFILE '...Divvy_Trips_2013.csv' INTO TABLE tripdata`: Loading the CSV data into the `tripdata` table.

### 2. **Data Cleaning and Preparation**
   - **Copying Data for Backup**:
     - `CREATE TABLE trip_data AS SELECT * FROM tripdata;`: Creating a backup of the original data for further modification.
   - **Modifying Data Types**:
     - `ALTER TABLE trip_data MODIFY COLUMN starttime DATETIME, MODIFY COLUMN stoptime DATETIME;`: Converting date columns to proper `DATETIME` format.
   - **Removing Unnecessary Characters**:
     - `UPDATE rides_data SET birthyear = TRIM(TRAILING '\r' FROM birthyear);`: Removing trailing characters.
   - **Handling Missing Values**:
     - `UPDATE rides_data SET birthyear = NULL WHERE LENGTH(birthyear) = 0;`: Converting blank birth years to `NULL`.
     - `UPDATE rides_data SET gender = NULL WHERE gender = '';`: Converting blank genders to `NULL`.
   - **Changing Data Types for Optimization**:
     - `ALTER TABLE rides_data MODIFY birthyear YEAR;`: Modifying birthyear to the `YEAR` data type.
     - `ALTER TABLE rides_data MODIFY COLUMN gender ENUM('Male', 'Female') NULL;`: Converting gender to `ENUM` for memory efficiency.

### 3. **Data Validation**
   - **Checking for Duplicate and Null Values**:
     - `SELECT COUNT(DISTINCT(trip_id))...`: Checking for duplicate `trip_id` values.
     - `SELECT * FROM rides_data WHERE trip_id IS NULL...`: Checking for `NULL` or invalid values in key columns.
   - **Validating Data Formats**:
     - `SELECT DISTINCT(gender) FROM rides_data;`: Checking distinct values for the gender column.

### 4. **Data Transformation**
   - **Creating Tables for Subscribers and Customers**:
     - `CREATE TABLE tripdata_subscriber AS SELECT * FROM rides_data WHERE usertype = 'Subscriber';`: Separating data for subscribers.
     - `CREATE TABLE tripdata_customer AS SELECT * FROM rides_data WHERE usertype = 'Customer';`: Separating data for customers.
   - **Adding Derived Columns**:
     - `CREATE TABLE rides_data_ AS SELECT *, DATE_FORMAT(STR_TO_DATE(starttime, '%Y-%m-%d %H:%i:%s'), '%W') AS dayofweek FROM rides_data;`: Adding a `dayofweek` column based on `starttime`.

### 5. **Exploratory Data Analysis (EDA)**
   - **Calculating Descriptive Statistics**:
     - **Average and Maximum Ride Duration**:
       - `SELECT AVG(tripduration)...`: Calculating average ride duration for overall data, customers, and subscribers.
       - `SELECT MAX(tripduration)...`: Calculating maximum ride duration for overall data, customers, and subscribers.
     - **Mode (Most Frequent Value) of Trip Duration**:
       - `WITH Mode_Calc AS (...) SELECT...`: Calculating the mode of trip duration for both customers and subscribers.
   - **Ride Counts by Day of the Week**:
     - `SELECT dayofweek, COUNT(DISTINCT(trip_id))...`: Counting the number of rides by day of the week for overall data, customers, and subscribers.
   - **Identifying Peak Hours**:
     - `SELECT HOUR(starttime)...`: Identifying the busiest hours for customers and subscribers.
   - **Monthly Ridership Trends**:
     - `SELECT MONTH(starttime)...`: Analyzing monthly ridership patterns for trend analysis.

### 6. **Reporting and Presentation**
   - **Identifying Peak and Low Periods**:
     - Reports peak ridership hours and busiest months for both customers and subscribers.


