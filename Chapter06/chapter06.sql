-- Listing 6.1 (Creating Departments and Employees Tables)
CREATE TABLE departments (
 dept_id bigserial,
 dept varchar(100),
 city varchar(100),
 CONSTRAINT dept_key PRIMARY KEY (dept_id), 
 CONSTRAINT dept_city_unique UNIQUE (dept, city)
);
-- Define primary with keyword 'CONSTRAINT;
-- Primary key is col or collection of cols uniquely identifying each row in table
-- Valid primary key must be unique for each row and no missing values
CREATE TABLE employees (
 emp_id bigserial,
 first_name varchar(100),
 last_name varchar(100),
 salary integer,
 dept_id integer REFERENCES departments (dept_id), -- Foreign key
 CONSTRAINT emp_key PRIMARY KEY (emp_id),
 CONSTRAINT emp_dept_unique UNIQUE (emp_id, dept_id)
);
-- Foreign key is Column values which refers to another table
-- Values must exist in this other table in primary key
-- Foreign key can contain duplicate values or be empty

INSERT INTO departments (dept, city)
VALUES
 ('Tax', 'Atlanta'),
 ('IT', 'Boston');
 
INSERT INTO employees (first_name, last_name, salary, dept_id)
VALUES
 ('Nancy', 'Jones', 62500, 1),
 ('Lee', 'Smith', 59300, 1),
 ('Soo', 'Nguyen', 83000, 2),
 ('Janet', 'King', 95000, 2);

--  Listing 6.2 (Querying Multiple Tables Using JOIN)
SELECT *  -- choose all columns from both tables
FROM employees JOIN departments
ON employees.dept_id = departments.dept_id; --specify cols to join tables on


-- Listing 6.3 (Creating Tables to Explore JOIN Types)
CREATE TABLE schools_left (
     id integer CONSTRAINT left_id_key PRIMARY KEY,
 left_school varchar(30)
);

CREATE TABLE schools_right (
     id integer CONSTRAINT right_id_key PRIMARY KEY,
 right_school varchar(30)
);

 INSERT INTO schools_left (id, left_school) VALUES
 (1, 'Oak Street School'),
 (2, 'Roosevelt High School'),
 (5, 'Washington Middle School'),
 (6, 'Jefferson High School');

INSERT INTO schools_right (id, right_school) VALUES
 (1, 'Oak Street School'),
 (2, 'Roosevelt High School'),
 (3, 'Morrison Elementary'),
 (4, 'Chase Magnet Academy'),
 (6, 'Jefferson High School');

--  Listing 6.4 (Using JOIN aka INNER JOIN)
-- Best use is when you have well-structured and well-maintained data
-- When you only need to find rows that exist in all tables you are joining
SELECT *
FROM schools_left JOIN schools_right
ON schools_left.id = schools_right.id;

-- Listing 6.5 (Using LEFT JOIN)
-- Will display all rows on Left table and any matching rows from the right table
-- If right table has no matching values to left, the row on right table will be empty
SELECT *
FROM schools_left LEFT JOIN schools_right
ON schools_left.id = schools_right.id

-- Listing 6.6 (Using RIGHT JOIN)
SELECT *
FROM schools_left RIGHT JOIN schools_right
ON schools_left.id = schools_right.id;

-- LEFT & RIGHT JOIN used when we want query results to contain all rows from one of the tables
-- Or to look for missing values eg comparing data between two diff time periods


-- Listing 6.7 (Using FULL OUTER JOIN)
-- Result gives each row from left table and matching rows/empty values on right table
-- Any leftover rows from right table that didnt have match with left table are placed at the bottom as well
-- Used to visualize the extent at which tables share matching values
SELECT * 
FROM schools_left FULL OUTER JOIN schools_right
ON schools_left.id = schools_right.id;


-- Listing 6.8 (Using CROSS JOIN)
-- Left table multiplied by right table
-- Each row on left table is repeated match for each row on right table
-- Best use would be eg to work out colors for each style of tshirt you have
SELECT * 
FROM schools_left CROSS JOIN schools_right;


-- Listing 6.9 (Using NULL to Find Rows with Missing Values)
SELECT *
FROM schools_left LEFT JOIN schools_right
ON schools_left.id = schools_right.id
WHERE schools_right.id IS NULL;


-- Listing 6.10 (Selecting Specific Columns in a JOIN)
SELECT schools_left.id, 
 schools_left.left_school, 
 schools_right.right_school
FROM schools_left LEFT JOIN schools_right
ON schools_left.id = schools_right.id;


-- Listing 6.11 (Simplifying JOIN Syntax with Table Aliases)
SELECT lt.id,
 lt.left_school, 
 rt.right_school
 FROM schools_left AS lt LEFT JOIN schools_right AS rt
ON lt.id = rt.id;


-- Listing 6.12 (Create Multiple Tables to JOIN )
CREATE TABLE schools_enrollment (
 id integer,
 enrollment integer
);

CREATE TABLE schools_grades (
 id integer,
 grades varchar(10)
);

INSERT INTO schools_enrollment (id, enrollment) 
VALUES
 (1, 360),
 (2, 1001),
 (5, 450),
 (6, 927);

INSERT INTO schools_grades (id, grades) 
VALUES
 (1, 'K-3'),
 (2, '9-12'),
 (5, '6-8'),
 (6, '9-12');

 SELECT lt.id, lt.left_school, en.enrollment, gr.grades
  FROM schools_left AS lt LEFT JOIN schools_enrollment AS en
 ON lt.id = en.id
  LEFT JOIN schools_grades AS gr
 ON lt.id = gr.id;
 

--  Listing 6.13 (Performing Math on Joined Table Columns)
CREATE TABLE us_counties_2000 (
 geo_name varchar(90),
 state_us_abbreviation varchar(2),
 state_fips varchar(2),
 county_fips varchar(3),
 p0010001 integer,
 p0010002 integer,
 p0010003 integer,
 p0010004 integer,
 p0010005 integer,
 p0010006 integer,
 p0010007 integer,
 p0010008 integer,
 p0010009 integer,
 p0010010 integer,
 p0020002 integer,
 p0020003 integer
);

COPY us_counties_2000
FROM 'C:\SQL\us_counties_2000.csv'
WITH (FORMAT CSV, HEADER);

 SELECT c2010.geo_name,
 c2010.state_us_abbreviation AS state,
 c2010.p0010001 AS pop_2010,
 c2000.p0010001 AS pop_2000,
 c2010.p0010001 - c2000.p0010001 AS raw_change,
 round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001) 
 / c2000.p0010001 * 100, 1 ) AS pct_change
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips
 AND c2010.county_fips = c2000.county_fips
  AND c2010.p0010001 <> c2000.p0010001 --Limit join to counties where pop col has diff value
  ORDER BY pct_change DESC;