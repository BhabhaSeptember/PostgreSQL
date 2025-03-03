-- 1)
SELECT *
FROM us_counties_2010 AS c2010 LEFT JOIN us_counties_2000 AS c2000
ON c2010.county_fips = c2000.county_fips
AND c2010.state_fips = c2000.state_fips
WHERE c2000.county_fips IS NULL

-- 2) Refers to Chapter5 (todo!!!)

-- 3)