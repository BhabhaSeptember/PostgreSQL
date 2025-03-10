-- Listing 11.1 (Extracting Components of timestamp Value)
-- Values in second arg are cast to timestamp with timezone
-- EST = Eastern Standard Time
-- UTC = Coordinated Universal Time
-- epoch = seconds elapsed before or after 12 am, January 1, 1970
SELECT 
 date_part('year', '2019-12-01 18:37:12 EST'::timestamptz) AS "year",
 date_part('month', '2019-12-01 18:37:12 EST'::timestamptz) AS "month",
 date_part('day', '2019-12-01 18:37:12 EST'::timestamptz) AS "day",
 date_part('hour', '2019-12-01 18:37:12 EST'::timestamptz) AS "hour",
 date_part('minute', '2019-12-01 18:37:12 EST'::timestamptz) AS "minute",
 date_part('seconds', '2019-12-01 18:37:12 EST'::timestamptz) AS "seconds",
 date_part('timezone_hour', '2019-12-01 18:37:12 EST'::timestamptz) AS "tz",
 date_part('week', '2019-12-01 18:37:12 EST'::timestamptz) AS "week",
 date_part('quarter', '2019-12-01 18:37:12 EST'::timestamptz) AS "quarter",
 date_part('epoch', '2019-12-01 18:37:12 EST'::timestamptz) AS "epoch";

-- below not commonly used
SELECT 
(extract('year' from '2019-12-01 18:37:12 EST'::timestamptz)) AS year_extract



-- Listing 11.2 (Making datetimes From Components)
-- PostgreSQL displays times relative to the client’s time zone or the time zone set in the database session
-- i.e. my PC is 2hours ahead of Lisbon so hour will be shown as 20 not 18 in my output
SELECT make_date(2018, 2, 22);
SELECT make_time(18, 4, 30.3); 
SELECT make_timestamptz(2018, 2, 22, 18, 4, 30.3, 'Europe/Lisbon');



-- Listing 11.3 (Retrieving Current Date and Time Using current & clock timestamp Functions)
CREATE TABLE current_time_example (
 time_id bigserial,
 current_timestamp_col timestamp with time zone,
clock_timestamp_col timestamp with time zone
);
INSERT INTO current_time_example (current_timestamp_col, clock_timestamp_col)
(SELECT current_timestamp, --records time of start of query(each row will therefore have same value)
 clock_timestamp() --records time of insertion of each row
 FROM generate_series(1,1000)); --function returns set of integers starting with 1, ending with 1000
SELECT * FROM current_time_example;



-- Listing 11.4 (Finding Your Time Zone Setting)
SHOW timezone;

-- below shows settings of every parameter on your PostgreSQL server
SHOW ALL;



-- Listing 11.5 (Showing Time Zone Abbreviations and Names)
SELECT * FROM pg_timezone_abbrevs;
SELECT * FROM pg_timezone_names;

-- below filters to search for specific location names and their timezones
-- is_dst = is timezone currently observing daylight saving time
SELECT * FROM pg_timezone_names
WHERE name LIKE 'Europe%';



-- Listing 11.6 (Setting The Time Zone)
SET timezone TO 'US/Pacific';
CREATE TABLE time_zone_test (
 test_date timestamp with time zone
);
INSERT INTO time_zone_test VALUES ('2020-01-01 4:00');
SELECT test_date
FROM time_zone_test;

-- setting timezone syntax changes output data type but data on server remains unchanged
SET timezone TO 'US/Eastern';
SELECT test_date
FROM time_zone_test;

SELECT test_date AT TIME ZONE 'Asia/Seoul'
FROM time_zone_test;



-- Listing 11.7 (Creating Table and Importing NYC Yellow Taxi Data)
CREATE TABLE nyc_yellow_taxi_trips_2016_06_01 (
 trip_id bigserial PRIMARY KEY,
 vendor_id varchar(1) NOT NULL,
 tpep_pickup_datetime timestamp with time zone NOT NULL,
 tpep_dropoff_datetime timestamp with time zone NOT NULL,
 passenger_count integer NOT NULL,
 trip_distance numeric(8,2) NOT NULL,
 pickup_longitude numeric(18,15) NOT NULL,
 pickup_latitude numeric(18,15) NOT NULL,
 rate_code_id varchar(2) NOT NULL,
 store_and_fwd_flag varchar(1) NOT NULL,
 dropoff_longitude numeric(18,15) NOT NULL,
 dropoff_latitude numeric(18,15) NOT NULL,
 payment_type varchar(1) NOT NULL,
 fare_amount numeric(9,2) NOT NULL,
 extra numeric(9,2) NOT NULL,
 mta_tax numeric(5,2) NOT NULL,
 tip_amount numeric(9,2) NOT NULL,
 tolls_amount numeric(9,2) NOT NULL,
 improvement_surcharge numeric(9,2) NOT NULL,
 total_amount numeric(9,2) NOT NULL
);

COPY nyc_yellow_taxi_trips_2016_06_01 (
 vendor_id,
 tpep_pickup_datetime,
 tpep_dropoff_datetime,
 passenger_count,
 trip_distance,
 pickup_longitude,
 pickup_latitude,
 rate_code_id,
 store_and_fwd_flag,
 dropoff_longitude,
 dropoff_latitude,
 payment_type,
 fare_amount,
 extra,
 mta_tax,
 tip_amount,
 tolls_amount,
 improvement_surcharge,
 total_amount 
 )
FROM 'C:\SQL\yellow_tripdata_2016_06_01.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');
 CREATE INDEX tpep_pickup_idx 
ON nyc_yellow_taxi_trips_2016_06_01 (tpep_pickup_datetime);


-- Listing 11.8 (Counting Taxi Trips By Hour)
SELECT
date_part('hour', tpep_pickup_datetime) AS trip_hour, --col1: 
 count(*) --col2: aggregate number of rides via count function i.e. adding all rides by the hour
 FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY trip_hour
ORDER BY trip_hour;



-- Listing 11.9 (Exporting taxi pickups to CSV File)
COPY 
 (SELECT
 date_part('hour', tpep_pickup_datetime) AS trip_hour,
 count(*)
 FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY trip_hour
 ORDER BY trip_hour
 )
TO 'C:\SQL\hourly_pickups_2016_06_01.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');



-- Listing 11.10 (Calculating Median Trip Time By Hour)
SELECT
date_part('hour', tpep_pickup_datetime) AS trip_hour,
percentile_cont(.5)
WITHIN GROUP (ORDER BY
 tpep_dropoff_datetime - tpep_pickup_datetime) AS median_trip
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY trip_hour
ORDER BY trip_hour;


-- Listing 11.11 (Creating Table to Hold Train Trip Data)
-- regardless of timezone supplied in insert statement of table below
-- our view of data will be Central time and times will be adjusted accordingly
SET timezone TO 'US/Central';

CREATE TABLE train_rides (
 trip_id bigserial PRIMARY KEY,
 segment varchar(50) NOT NULL,
 departure timestamp with time zone NOT NULL,
 arrival timestamp with time zone NOT NULL
);
INSERT INTO train_rides (segment, departure, arrival)
VALUES
 ('Chicago to New York', '2017-11-13 21:30 CST', '2017-11-14 18:23 EST'),
 ('New York to New Orleans', '2017-11-15 14:15 EST', '2017-11-16 19:32 CST'),
 ('New Orleans to Los Angeles', '2017-11-17 13:45 CST', '2017-11-18 9:00 PST'),
 ('Los Angeles to San Francisco', '2017-11-19 10:10 PST', '2017-11-19 21:24 PST'),
 ('San Francisco to Denver', '2017-11-20 9:10 PST', '2017-11-21 18:38 MST'),
 ('Denver to Chicago', '2017-11-22 19:10 MST', '2017-11-23 14:50 CST');
SELECT * FROM train_rides;



-- Listing 11.12 (Calculating Length of Each Trip Segment)
-- to_char = formatting function turns departure timestamp column to string of characters 
-- YYYY-MM-DD specifies ISO format for date
-- HH12MI a.m = 12 hour clock , minutes, a.m. shows day/night
-- 
SELECT 
segment,
to_char(departure, 'YYYY-MM-DD HH12:MI a.m. TZ') AS departure,
arrival - departure AS segment_time
FROM train_rides;



-- Listing 11.13 (Calculating Cumulative Intervals Using OVER)
SELECT segment,
 arrival - departure AS segment_time,
 sum(arrival - departure) OVER (ORDER BY trip_id) AS cume_time
FROM train_rides;



-- Listing 11.14 (Better Formatting For Cumulative Trip Time)
SELECT segment,
 arrival - departure AS segment_time,
 sum(date_part('epoch', (arrival - departure))) 
 OVER (ORDER BY trip_id) * interval '1 second' AS cume_time
FROM train_rides;