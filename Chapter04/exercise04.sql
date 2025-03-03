-- 1) 
COPY movies_table
FROM 'C:\SQL\movies_file.txt'
WITH (FORMAT CSV, HEADER, DELIMITER ':', QUOTE '#');


-- 2)
COPY (
SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent  
FROM us_counties_2010
ORDER BY housing_unit_count_100_percent DESC
LIMIT 20
)
TO 'C:\SQL\us_counties_2010_most_housing_units_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');


-- 3) 
-- No we need a data type of numeric(8, 3)
-- precision will be 8 because all values in the column have total of 8 digits
-- scale will be 3 because all values have 3 digits after the decimal point

