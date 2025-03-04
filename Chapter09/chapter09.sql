-- Listing 9.1 (Importing the FSIS Meat, Poultry, and Egg Inspection Directory)
CREATE TABLE meat_poultry_egg_inspect (
    est_number varchar(50) PRIMARY KEY,
    company varchar(100),
    street varchar(100),
    city varchar(30),
    st varchar(2),
    zip varchar(5),
    phone varchar(14),
    grant_date date,
    activities text,
    dbas text
);

COPY meat_poultry_egg_inspect
FROM 'C:\SQL\MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

CREATE INDEX company_idx ON meat_poultry_egg_inspect (company);



SELECT count(*) FROM meat_poultry_egg_inspect;


-- Listing 9.2 (Finding Multiple Companies At The Same Address)
SELECT company,
 street,
 city,
 st,
 count(*) AS address_count
FROM meat_poultry_egg_inspect
GROUP BY company, street, city, st
HAVING count(*) > 1 --returns duplicate addresses for a company i.e. show cases where more than one row has same combo of values
ORDER BY company, street, city, st;



-- Listing 9.3 (Checking For Missing Values)
SELECT st,
 count(*) AS st_count
FROM meat_poultry_egg_inspect
GROUP BY st
ORDER BY st;



-- Listing 9.4 (Using IS NULL To Find Missing Values In The st Column)
SELECT est_number,
 company,
 city, 
 st,
 zip
FROM meat_poultry_egg_inspect
WHERE st IS NULL;


-- Listing 9.5 (Using GROUP BY and count() to find inconsistent company names)
SELECT company, 
 count(*) AS company_count
FROM meat_poultry_egg_inspect
GROUP BY company
ORDER BY company ASC;


-- Listing 9.6 (Using length() and count() To Test zip Column)
SELECT length(zip),
 count(*) AS length_count
FROM meat_poultry_egg_inspect
GROUP BY length(zip)
ORDER BY length(zip) ASC;


-- Listing 9.7 (Filtering with length() To Find Short zip Values)
SELECT st, 
 count(*) AS st_count
FROM meat_poultry_egg_inspect
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;



-- Modifying Tables With ALTER TABLE

-- adding column to table
ALTER TABLE table_name ADD COLUMN column_name data_type;

-- remove column from table
ALTER TABLE table_name DROP COLUMN column_name;

-- change data type of a column
ALTER TABLE table_name ALTER COLUMN column_name SET DATA TYPE data_type;

-- add NOT NULL constraint to column
ALTER TABLE table_name ALTER COLUMN column_name SET NOT NULL;

-- remove NOT NULL constraint from column
ALTER TABLE table_name ALTER COLUMN column_name DROP NOT NULL;



-- Modfying Values With UPDATE

-- update data in each row of column
-- new value can be string, number, name of another column or query that generates a value
UPDATE table_name
SET column_name = value; 


-- update values in multiple columns 
UPDATE table_name
SET column_a = value,
 column_b = value;

--  restrict update to particular rows 
UPDATE table_name
SET column_name = value
WHERE criteria;

-- update table with values from another table
UPDATE table_name
SET column_name = (SELECT column
 FROM table_b
 WHERE table.column = table_b.column) -- value is result of SELECT query
WHERE EXISTS (SELECT column
 FROM table_b
 WHERE table.column = table_b.column);

-- updating across tables
UPDATE table_name
SET column = table_b.column
FROM table_b
WHERE table.column = table_b.column;




-- Listing 9.8 (Creating Backup Table)
CREATE TABLE meat_poultry_egg_inspect_backup AS
SELECT * FROM meat_poultry_egg_inspect;


-- Listing 9.9 (Creating Column Copy)
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN st_copy varchar(2);
UPDATE meat_poultry_egg_inspect
SET st_copy = st;



-- Listing 9.10 (Checking Values In The st and st_copy Columns)
SELECT st,
 st_copy
FROM meat_poultry_egg_inspect
ORDER BY st;


-- Listing 9.11 (Updating Rows Where Values Are Missing)
SELECT st,
 st_copy, est_number
FROM meat_poultry_egg_inspect
ORDER BY st;


UPDATE meat_poultry_egg_inspect
SET st = 'MN'
WHERE est_number = 'V18677A';

UPDATE meat_poultry_egg_inspect
SET st = 'AL'
WHERE est_number = 'M45319+P45319';

UPDATE meat_poultry_egg_inspect
SET st = 'WI'
WHERE est_number = 'M263A+P263A+V263A';

-- check
SELECT est_number,
 company,
 city, 
 st,
 zip
FROM meat_poultry_egg_inspect
WHERE st IS NULL;


-- Listing 9.12 (Restoring Original Values)
-- Option1
UPDATE meat_poultry_egg_inspect
SET st = st_copy;

-- Option2
UPDATE meat_poultry_egg_inspect original
SET st = backup.st
FROM meat_poultry_egg_inspect_backup backup
WHERE original.est_number = backup.est_number;


-- Listing 9.13 (Updating Values For Consistency)
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN company_standard varchar(100);
UPDATE meat_poultry_egg_inspect
SET company_standard = company;



-- Listing 9.14 (Using UPDATE To Modufy Field Values Matching A String)
UPDATE meat_poultry_egg_inspect
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%';

SELECT company, company_standard
FROM meat_poultry_egg_inspect
WHERE company LIKE 'Armour%';


-- Listing 9.15 (Creating Backup Column for zip Column)
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN zip_copy varchar(5);
UPDATE meat_poultry_egg_inspect
SET zip_copy = zip;



-- Listing 9.16 (Modifying Codes In zip Column Missing Two Leading Zeros)
-- NOTE: "||" - pipe symbol performs concatenation i.e abc||123 = abc123
UPDATE meat_poultry_egg_inspect
SET zip = '00' || zip --concatenate two zeros infront of zipcode
 WHERE st IN('PR','VI') AND length(zip) = 3;




-- Listing 9.17 (Modify Codes In zip Column Missing One Leading Zero)
UPDATE meat_poultry_egg_inspect
SET zip = '0' || zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND length(zip) = 4;




-- Listing 9.18 (Updating Values Across Tables - Creating New Table)
CREATE TABLE state_regions (
 st varchar(2) PRIMARY KEY,
 region varchar(20) NOT NULL
);
COPY state_regions
FROM 'C:\SQL\state_regions.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');


-- Listing 9.19 (Adding And Updating New Column)
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN inspection_date date;
 UPDATE meat_poultry_egg_inspect AS inspect
 SET inspection_date = '2019-12-01'
 WHERE EXISTS (SELECT state_regions.region 
 FROM state_regions 
 WHERE inspect.st = state_regions.st 
 AND state_regions.region = 'New England');



--  Listing 9.20 (Viewing Updated inspection_date Values)
SELECT st, inspection_date 
FROM meat_poultry_egg_inspect
GROUP BY st, inspection_date
ORDER BY st;


