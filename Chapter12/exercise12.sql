-- 1)
-- a)
WITH temps_collapsed (station_name, max_temperature_group) AS
 (SELECT station_name,
 CASE WHEN max_temp >= 90 THEN '90 or more'
 WHEN max_temp BETWEEN 88 AND 89 THEN '88-89'
 WHEN max_temp BETWEEN 86 AND 87 THEN '86-87'
 WHEN max_temp BETWEEN 84 AND 85 THEN '84-85'
 WHEN max_temp BETWEEN 82 AND 83 THEN '82-83'
  WHEN max_temp BETWEEN 80 AND 81 THEN '80-81'
 ELSE '79 or less'
 END
 FROM temperature_readings
 WHERE station_name ILIKE '%Waikiki%')
  SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY station_name, count(*) DESC;

-- b) Waikiki's daily maximum temperature falls most often...
-- ...between 86-87 degrees Fahrenheit


-- 2)
SELECT * 
FROM crosstab('SELECT  
        flavor, 
        office, 
        count(*)
FROM ice_cream_survey
 GROUP BY flavor, office
 ORDER BY flavor',

'SELECT office 
 FROM ice_cream_survey
 GROUP BY office
 ORDER BY office')
 AS (flavour varchar(20),
 downtown bigint,
 midtown bigint,
 uptown bigint);