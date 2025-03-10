-- 1)
-- a)
SELECT * FROM pg_timezone_names
WHERE name LIKE '%York%';

SET timezone TO 'America/New_York';

SELECT 
trip_id,
tpep_pickup_datetime AS pickup_tz,
tpep_dropoff_datetime AS dropoff_tz,
(tpep_dropoff_datetime - tpep_pickup_datetime ) AS ride_length
FROM nyc_yellow_taxi_trips_2016_06_01
ORDER BY ride_length DESC

-- b) Well the shortest trip is -00:04:33 and the longest is 23:59:37
-- These are alarming figures especially the negative trip length
-- Clearly something is wrong with data capturing...
-- ...because a single trip within NYC cannot present such figures logically



-- 2)
SELECT * FROM pg_timezone_names
WHERE name LIKE '%London%'; -- Europe/London

SELECT * FROM pg_timezone_names
WHERE name LIKE '%Johannesburg%'; -- Africa/Johannesburg

SELECT * FROM pg_timezone_names
WHERE name LIKE '%Moscow%'; -- Europe/Moscow

SELECT * FROM pg_timezone_names
WHERE name LIKE '%Melbourne%'; -- Australia/Melbourne


SELECT
'2100-01-01' AT TIME ZONE 'America/New_York' AS NYC,
'2100-01-01' AT TIME ZONE 'Europe/London' AS London,
'2100-01-01' AT TIME ZONE 'Africa/Johannesburg' AS JHB,
'2100-01-01' AT TIME ZONE 'Europe/Moscow' AS Moscow,
'2100-01-01' AT TIME ZONE 'Australia/Melbourne' AS Melbourne


-- 3)
--Relates to Chapter10