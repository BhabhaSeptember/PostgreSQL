-- Listing 15.1 (Creating a View Displaying Nevada 2010 Counties)
 CREATE OR REPLACE VIEW nevada_counties_pop_2010 AS
  SELECT geo_name,
           state_fips,
           county_fips,
           p0010001 AS pop_2010
    FROM us_counties_2010
    WHERE state_us_abbreviation = 'NV'
    ORDER BY county_fips;



-- Listing 15.2 (Querying A View)
 SELECT * 
FROM nevada_counties_pop_2010
 LIMIT 5;



-- Listing 15.3 (Creating a View Showing Population Change for US Counties)
 CREATE OR REPLACE VIEW county_pop_change_2010_2000 AS
 SELECT c2010.geo_name,
           c2010.state_us_abbreviation AS st,
           c2010.state_fips,
           c2010.county_fips,
           c2010.p0010001 AS pop_2010,
           c2000.p0010001 AS pop_2000,
           round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001) 
               / c2000.p0010001 * 100, 1 ) AS pct_change_2010_2000
               FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
    ON c2010.state_fips = c2000.state_fips
       AND c2010.county_fips = c2000.county_fips
    ORDER BY c2010.state_fips, c2010.county_fips;



-- Listing 15.4 (Selecting Columns From a View)
 SELECT geo_name,
       st,
        pop_2010,
         pct_change_2010_2000
 FROM county_pop_change_2010_2000
 WHERE st = 'NV'
 LIMIT 5;



-- Listing 15.5 (Creating a View On a Table)
 CREATE OR REPLACE VIEW employees_tax_dept AS
     SELECT emp_id,
            first_name,
            last_name,
            dept_id
     FROM employees
      WHERE dept_id = 1 --show only dept_id 1 rows
     ORDER BY emp_id
      WITH LOCAL CHECK OPTION; --rejects insert/update not meeting WHERE clause criteria



-- Listing 15.6 (Inserting Rows Using a View)
 INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
 VALUES ('Suzanne', 'Legere', 1);

INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
 VALUES ('Jamil', 'White', 2);
-- ERROR:  new row violates check option for view "employees_tax_dept"

 SELECT * FROM employees_tax_dept;

 SELECT * FROM employees;




-- Listing 15.7 (Updating a Row Using a View)
UPDATE employees_tax_dept
 SET last_name = 'Le Gere' 
WHERE emp_id = 5;
 SELECT * FROM employees_tax_dept; 



-- Listing 15.8 (Deleting Row Using View)
 DELETE FROM employees_tax_dept
 WHERE emp_id = 5;



-- Listing 15.9 (Creating a percent_change() Function)
CREATE OR REPLACE FUNCTION
 percent_change(new_value numeric,
               old_value numeric,
               decimal_places integer DEFAULT 1)
RETURNS numeric AS
'SELECT round(
        ((new_value - old_value) / old_value) * 100, decimal_places
 );'
LANGUAGE SQL
IMMUTABLE --function wont make changes to db
RETURNS NULL ON NULL INPUT;



-- Listing 15.10 (Testing Function)
SELECT percent_change(110, 108, 2);



-- Listing 15.11 (Testing Function)
SELECT c2010.geo_name,
       c2010.state_us_abbreviation AS st,
       c2010.p0010001 AS pop_2010,
       percent_change(c2010.p0010001, c2000.p0010001) AS pct_chg_func,
        round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
           / c2000.p0010001 * 100, 1 ) AS pct_chg_formula
 FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
 ON c2010.state_fips = c2000.state_fips 
   AND c2010.county_fips = c2000.county_fips
   ORDER BY pct_chg_func DESC
 LIMIT 5;



-- Listing 15.12 (Adding Column to Table)
 ALTER TABLE teachers ADD COLUMN personal_days integer;
 SELECT first_name,
       last_name,
       hire_date,
       personal_days
 FROM teachers;



-- Listing 15.13 (Creating Function)
 CREATE OR REPLACE FUNCTION update_personal_days() 
  RETURNS void AS --void = function doesnt return data
  $$ --PL/pgSQL convention to makr start & end of function command's string
  BEGIN
    UPDATE teachers
    SET personal_days =
    CASE WHEN (now() - hire_date) BETWEEN '5 years'::interval 
                                      AND '10 years'::interval THEN 4
             WHEN (now() - hire_date) > '10 years'::interval THEN 5
             ELSE 3 
        END;
    RAISE NOTICE 'personal_days updated!';
     END;
      $$ LANGUAGE plpgsql;


SELECT update_personal_days(); --runs the function



-- Listing 15.14 (Enabling PL/Python Procedural Language)
CREATE EXTENSION plpython3u;



-- Listing 15.15 ()
--dont need 'BEGIN & END' block after $$
--import re = python's regular expressions module
--variable 'cleaned' = results of pythons regular expression function called sub()
-- sub looks for a space followed by the word County in the input_string passed into the function 
-- ...and substitutes an empty string, which is denoted by two apostrophes
-- NOTE: Python is strict with indentation
CREATE OR REPLACE FUNCTION trim_county(input_string text)
RETURNS text AS 
$$
import re
cleaned = re.sub(r' County', '', input_string)
return cleaned
$$ LANGUAGE plpython3u;

-- Listing 15.16 (Testing Function)
 SELECT geo_name,
       trim_county(geo_name)
 FROM us_counties_2010
 ORDER BY state_fips, county_fips
 LIMIT 5;



-- Listing 15.17 (Creating grades And grades_history Tables)





-- Listing 15.18()
-- Listing 15.19 ()
-- Listing 15.20 ()
-- Listing 15.21 ()
-- Listing 15.22 ()
-- Listing 15.23 ()
-- Listing 15.24 ()

