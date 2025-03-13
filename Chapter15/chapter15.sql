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
 CREATE TABLE grades (
    student_id bigint,
    course_id bigint, 
    course varchar(30) NOT NULL,
    grade varchar(5) NOT NULL,
 PRIMARY KEY (student_id, course_id)
 );

  INSERT INTO grades
 VALUES
    (1, 1, 'Biology 2', 'F'),
    (1, 2, 'English 11B', 'D'),
    (1, 3, 'World History 11B', 'C'),
    (1, 4, 'Trig 2', 'B');

CREATE TABLE grades_history (
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    change_time timestamp with time zone NOT NULL,
    course varchar(30) NOT NULL,
    old_grade varchar(5) NOT NULL,
    new_grade varchar(5) NOT NULL,
 PRIMARY KEY (student_id, course_id, change_time)
 );



-- Listing 15.18(Creating record_if_grade_changed() Function)
--  <> operator checks if there is a difference. only update if different
--  for each row that is changed trigger passes two collections of data into record_if_grade_changed() function

 CREATE OR REPLACE FUNCTION record_if_grade_changed()
 RETURNS trigger AS
 $$
 BEGIN
  IF NEW.grade <> OLD.grade THEN
    INSERT INTO grades_history (
        student_id,
        course_id,
        change_time,
        course,
        old_grade,
        new_grade)
    VALUES
        (OLD.student_id,
         OLD.course_id,
         now(),
         OLD.course,
          OLD.grade,
           NEW.grade);
         END IF;
         RETURN NEW;
 END;
 $$ LANGUAGE plpgsql;



-- Listing 15.19 (Creating grades_update Trigger)
-- specify that trigger must fire after update occurs on grades row
-- can use BEFORE or INSTEAD OF for other use cases
-- FOR EACH ROW alternative is FOR EACH STATEMENT which runs procedure of trigger just once and not for each row
 CREATE TRIGGER grades_update
  AFTER UPDATE
  ON grades
 FOR EACH ROW
 EXECUTE PROCEDURE record_if_grade_changed();



-- Listing 15.20 (Testing grades_update Trigger)
 UPDATE grades
 SET grade = 'C'
 WHERE student_id = 1 AND course_id = 1;


  SELECT student_id,
       change_time,
       course,
       old_grade,
       new_grade
 FROM grades_history;



-- Listing 15.21 (Creating a temperature_test Table)
 CREATE TABLE temperature_test (
    station_name varchar(50),
    observation_date date,
    max_temp integer,
    min_temp integer,
    max_temp_group varchar(40),
 PRIMARY KEY (station_name, observation_date)
 );



-- Listing 15.22 (Creating classify_max_temp() Function)
-- Note difference between SQL syntax and PL/pgSQL syntax for CASE...WHEN...THEN
-- a) semi-colon at end of each WHEN THEN clause
-- b) use of (:=) assignment operator
 CREATE OR REPLACE FUNCTION classify_max_temp()
    RETURNS trigger AS
 $$
 BEGIN
  CASE 
       WHEN NEW.max_temp >= 90 THEN
           NEW.max_temp_group := 'Hot';
            WHEN NEW.max_temp BETWEEN 70 AND 89 THEN
           NEW.max_temp_group := 'Warm';
       WHEN NEW.max_temp BETWEEN 50 AND 69 THEN
           NEW.max_temp_group := 'Pleasant';
       WHEN NEW.max_temp BETWEEN 33 AND 49 THEN
           NEW.max_temp_group :=  'Cold';
       WHEN NEW.max_temp BETWEEN 20 AND 32 THEN
           NEW.max_temp_group :=  'Freezing';
       ELSE NEW.max_temp_group :=  'Inhumane';
    END CASE;
    RETURN NEW;
 END;
 $$ LANGUAGE plpgsql;



-- Listing 15.23 (Creating temperature_insert Trigger)
--  value created before inserting into the table
 CREATE TRIGGER temperature_insert
 BEFORE INSERT
    ON temperature_test
 FOR EACH ROW
 EXECUTE PROCEDURE classify_max_temp();



-- Listing 15.24 (Testing temperature_insert Trigger)
 INSERT INTO temperature_test (station_name, observation_date, max_temp, min_temp)
 VALUES
    ('North Station', '1/19/2019', 10, -3),
    ('North Station', '3/20/2019', 28, 19),
    ('North Station', '5/2/2019', 65, 42),
    ('North Station', '8/9/2019', 93, 74);
 SELECT * FROM temperature_test;

