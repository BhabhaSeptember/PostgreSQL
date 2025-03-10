-- Listing 12.1 (Using a Subquery in a WHERE clause)
-- correlated subquery example?
SELECT geo_name,
 state_us_abbreviation,
 p0010001 --total population
FROM us_counties_2010
WHERE p0010001 >= (
 SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
 FROM us_counties_2010
 )
ORDER BY p0010001 DESC;



-- Listing 12.2 (Using Subquery in WHERE clause with DELETE)
-- correlated subquery example?
CREATE TABLE us_counties_2010_top10 AS
SELECT * FROM us_counties_2010;

DELETE FROM us_counties_2010_top10
WHERE p0010001 < (
 SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
 FROM us_counties_2010_top10
 ); 



-- Listing 12.3 (Subquery as a derived table in FROM clause)
SELECT 
 round(calcs_table.average, 0) AS average, --rounding off to zero decimal places?
 calcs_table.median,
 round(calcs_table.average - calcs_table.median, 0) AS median_average_diff --rounding off to zero decimal places?
FROM (
SELECT avg(p0010001) AS average,
 percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)::numeric(10,1) AS median
 FROM us_counties_2010
 ) AS calcs_table; --calcs is alias of derived table from the subquery



-- Listing 12.4 (Joining Two derived tables)
SELECT census.state_us_abbreviation AS st,
 census.st_population,
 plants.plant_count,
 round((plants.plant_count/census.st_population::numeric(10,1))*1000000, 1)
 AS plants_per_million
 FROM
 (
    SELECT st,
 count(*) AS plant_count
 FROM meat_poultry_egg_inspect
 GROUP BY st
 )
 AS plants --derived table 1
JOIN
 (
    SELECT state_us_abbreviation,
 sum(p0010001) AS st_population
 FROM us_counties_2010
 GROUP BY state_us_abbreviation
 ) 
 AS census --derived table 2
  ON plants.st = census.state_us_abbreviation
ORDER BY plants_per_million DESC



-- Listing 12.5 (Adding Subquery to Column List)
SELECT geo_name,
 state_us_abbreviation AS st,
 p0010001 AS total_pop,
 (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010) AS us_median 
FROM us_counties_2010;


-- Listing 12.6 (Using Aubquery Expression in a Calculation)
SELECT geo_name,
 state_us_abbreviation AS st,
 p0010001 AS total_pop,
 (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010) AS us_median,
p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010) AS diff_from_median 
FROM us_counties_2010
 WHERE (p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010))
 BETWEEN -1000 AND 1000;


-- Generating Values for the IN Operator
-- output below shows names of employees who have id values matching those in retirees
SELECT first_name, last_name 
FROM employees
WHERE id IN (
 SELECT id 
 FROM retirees);

-- below query returns all names from employees table as long as 
-- ...subquery finds atleast one matching value in id in a retirees table
 SELECT first_name, last_name 
FROM employees
WHERE EXISTS (
 SELECT id 
 FROM retirees);

--  below is extension of above
-- filters output to show only employees whose id's match in retirees table instead of the whole table
-- below helpful with joining more than one column
SELECT first_name, last_name 
FROM employees
WHERE EXISTS (
 SELECT id 
 FROM retirees 
 WHERE id = employees.id);



-- Listing 12.7 (Using CTE To Find Large Counties)
-- CTE = Common Table Expression
-- WITH...AS block defines CTE's temporary table
WITH
 large_counties (geo_name, st, p0010001)
AS
 (
     SELECT geo_name, state_us_abbreviation, p0010001
 FROM us_counties_2010
 WHERE p0010001 >= 100000
 )
SELECT 
st, 
count(*) --counts states with number of counties with population of 100_000 or more
FROM large_counties
GROUP BY st
ORDER BY count(*) DESC;

-- above can be done using SELECT query instead of CTE
SELECT state_us_abbreviation, count(*)
FROM us_counties_2010
WHERE p0010001 >= 100000
GROUP BY state_us_abbreviation
ORDER BY count(*) DESC;



-- Listing 12.8 (Using CTE To Join Tables refer to 12.4 above)
WITH
 counties (st, population) AS
 (SELECT state_us_abbreviation, sum(population_count_100_percent)
 FROM us_counties_2010 
 GROUP BY state_us_abbreviation), --temp table 1
  plants (st, plants) AS
 (SELECT st, count(*) AS plants
 FROM meat_poultry_egg_inspect
 GROUP BY st) --temp table 2
 SELECT counties.st,
 population,
 plants,
 round((plants/population::numeric(10,1)) * 1000000, 1) AS per_million
  FROM counties JOIN plants
ON counties.st = plants.st
ORDER BY per_million DESC;


-- Listing 12.9 (Using CTE to Minimize Redundant Code refer to 12.6 above)
--each row from the first table is combined with every row from the second table.
WITH us_median AS 
 (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) AS us_median_pop
 FROM us_counties_2010)
SELECT geo_name,
 state_us_abbreviation AS st,
 p0010001 AS total_pop,
 us_median_pop,
 p0010001 - us_median_pop AS diff_from_median 
 FROM us_counties_2010 CROSS JOIN us_median 
WHERE (p0010001 - us_median_pop)
 BETWEEN -1000 AND 1000;


-- INSTALLING crosstab() FUNCTION FOR CROSS TABULATION
CREATE EXTENSION tablefunc;


-- Listing 12.10 (Creating and Filling The ice_cream_survey Table)
CREATE TABLE ice_cream_survey (
 response_id integer PRIMARY KEY,
 office varchar(20),
 flavor varchar(20)
);
COPY ice_cream_survey
FROM 'C:\SQL\ice_cream_survey.csv'
WITH (FORMAT CSV, HEADER);



-- Listing 12.11 (Generating The Ice Cream Survey Crosstab)
SELECT * --select everything from the contents of crosstab() function
-- subquery 1 generates data for crosstab
--office = rows
--flavor = columns
--count(*)= values in each intersecting cell
FROM crosstab('SELECT  
        office, 
        flavor, 
        count(*)
FROM ice_cream_survey
 GROUP BY office, flavor
 ORDER BY office',
--  subquery 2 produces set of category names for columns
-- can return only one column
'SELECT flavor 
 FROM ice_cream_survey
 GROUP BY flavor
 ORDER BY flavor')
--  specify names and data types of crosstabs output columns
 AS (office varchar(20),
 chocolate bigint,
 strawberry bigint,
 vanilla bigint);



-- Listing 12.12 (Creating and Filling temperature_readings Table)
CREATE TABLE temperature_readings (
 reading_id bigserial,
 station_name varchar(50),
 observation_date date,
 max_temp integer,
 min_temp integer
);
COPY temperature_readings 
 (station_name, observation_date, max_temp, min_temp)
FROM 'C:\SQL\temperature_readings.csv'
WITH (FORMAT CSV, HEADER);



-- Listing 12.13 (Temperature Reading Crosstab)
SELECT *
-- median max temp for each month at each station
FROM crosstab('SELECT
            station_name,
            date_part(''month'', observation_date),
            percentile_cont(.5) WITHIN GROUP (ORDER BY max_temp) 
 FROM temperature_readings
 GROUP BY station_name,
 date_part(''month'', observation_date)
 ORDER BY station_name',
 
 'SELECT month
 FROM  generate_series(1,12) month')
AS (station varchar(50),
 jan numeric(3,0),
 feb numeric(3,0),
 mar numeric(3,0),
 apr numeric(3,0),
 may numeric(3,0),
 jun numeric(3,0),
 jul numeric(3,0),
 aug numeric(3,0),
 sep numeric(3,0),
 oct numeric(3,0),
 nov numeric(3,0),
 dec numeric(3,0)
);



-- Listing 12.14 (Reclassifying Temperature Data With CASE)
SELECT max_temp,
 CASE WHEN max_temp >= 90 THEN 'Hot'
 WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
 WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
 WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
 WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
 ELSE 'Inhumane'
 END AS temperature_group
FROM temperature_readings;



-- Listing 12.15 (Using CASE in a CTE)
WITH temps_collapsed (station_name, max_temperature_group) AS
 (SELECT station_name,
 CASE WHEN max_temp >= 90 THEN 'Hot'
 WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
 WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
 WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
 WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
 ELSE 'Inhumane'
 END
 FROM temperature_readings)
  SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY station_name, count(*) DESC;