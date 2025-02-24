-- Listing 2.1 (Using wild card select statement)
SELECT * FROM teachers;

-- Listing 2.2 (Querying subset of columns)
SELECT last_name, first_name, salary FROM teachers;

-- Listing 2.3 (Querying distinct values)
SELECT DISTINCT school 
FROM teachers;

-- Listing 2.4 (Querying only unique salaries and schools)
SELECT DISTINCT school, salary 
FROM teachers;

-- Listing 2.5 (Sorting columns)
SELECT first_name, last_name, salary 
FROM teachers
ORDER BY salary DESC; 
-- NOTE : ASC is default i.e. do not need specify if handling one column


-- Listing 2.6 (Sorting multiple columns)
SELECT last_name, school, hire_date 
FROM teachers
ORDER BY school ASC, hire_date DESC;


-- Listing 2.7 (Filtering rows)
SELECT last_name, school, hire_date
FROM teachers
WHERE school = 'Myers Middle School';

SELECT first_name, last_name, school
FROM teachers
WHERE first_name = 'Janet';

SELECT school
FROM teachers
WHERE school != 'F.D. Roosevelt HS';

SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '2000-01-01';

SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 43500;

SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary BETWEEN 40000 AND 65000;

-- Listing 2-8 (Filtering with LIKE and ILIKE)
SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%'; 
-- LIKE is case sensitive, % is wildcard which matches results that have atlease 'sam'

SELECT first_name
FROM teachers
 WHERE first_name ILIKE 'sam%';
--  ILIKE is case insensitive


-- Listing 2.9 (Combining operators with AND and OR)
SELECT *
FROM teachers
WHERE school = 'Myers Middle School'
 AND salary < 40000;
-- AND requires all conditions to be true otherwise query will not execute

SELECT *
FROM teachers
WHERE last_name = 'Cole'
 OR last_name = 'Bush'; 
--  OR requires only one condition to be true for query to be executed


SELECT *
FROM teachers
WHERE school = 'F.D. Roosevelt HS'
 AND (salary < 38000 OR salary > 40000);


--  Listing 2.10
SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC; 
-- DESC Hire date is arranged from most recent date to oldest/most past tense
