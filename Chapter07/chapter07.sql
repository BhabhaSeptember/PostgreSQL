-- Listing 7.1 (Primary Key Syntax)

-- Column constraint
CREATE TABLE natural_key_example (
 license_id varchar(10) CONSTRAINT license_key PRIMARY KEY, 
 first_name varchar(50),
 last_name varchar(50)
);

CREATE TABLE natural_key_example (
 license_id varchar(10) PRIMARY KEY, --can ommit CONSTRAINT & key_name
 first_name varchar(50),
 last_name varchar(50)
);


DROP TABLE natural_key_example;

-- Table constraint
CREATE TABLE natural_key_example (
 license_id varchar(10),
 first_name varchar(50),
 last_name varchar(50),
CONSTRAINT license_key PRIMARY KEY (license_id)
);


-- Listing 7.2 (Example of Primary Key Violation)
INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Sam', 'Tracy'); --results in error: duplicate violates unique primary key constraint


-- Listing 7.3 (Creating Composite Primary Key i.e. combo of columns as primary key)
CREATE TABLE natural_key_composite_example (
 student_id varchar(10),
 school_day date,
 present boolean,
 CONSTRAINT student_key PRIMARY KEY (student_id, school_day) 
);

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/22/2017', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/23/2017', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/23/2017', 'N'); --duplicate error results



-- Listing 7.5 (Creating Auto-incrementing Surrogate Key)
CREATE TABLE surrogate_key_example (
 order_number bigserial,
 product_name varchar(50),
 order_date date,
 CONSTRAINT order_key PRIMARY KEY (order_number) 
);

INSERT INTO surrogate_key_example (product_name, order_date)
VALUES ('Beachball Polish', '2015-03-17'),
 ('Wrinkle De-Atomizer', '2017-05-22'),
 ('Flux Capacitor', '1985-10-26');
SELECT * FROM surrogate_key_example;


-- Listing 7.6 (Foreign Keys)
CREATE TABLE licenses (
 license_id varchar(10),
 first_name varchar(50),
 last_name varchar(50),
CONSTRAINT licenses_key PRIMARY KEY (license_id) --natural primary key
);

CREATE TABLE registrations (
 registration_id varchar(10),
 registration_date date,
 license_id varchar(10) REFERENCES licenses (license_id),
 CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);

INSERT INTO licenses (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A203391', '2017/03/17', 'T229901');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A75772', '2017/03/17', 'T000001'); --error: license_id does not exist in licenses table, violates foreign key contstraint


-- Automatically Deleting Related Records with CASCADE
CREATE TABLE registrations (
 registration_id varchar(10),
 registration_date date,
 license_id varchar(10) REFERENCES licenses (license_id) ON DELETE CASCADE,
 CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);



-- Listing 7.7 (The CHECK Constraint)
CREATE TABLE check_constraint_example (
 user_id bigserial,
 user_role varchar(50),
 salary integer,
 CONSTRAINT user_id_key PRIMARY KEY (user_id), --surrogate primary key
 CONSTRAINT check_role_in_list CHECK (user_role IN('Admin', 'Staff')),
 CONSTRAINT check_salary_not_zero CHECK (salary > 0)
);


-- Combining more than one test in single CHECK statement
CONSTRAINT grad_check CHECK (credits >= 120 AND tuition = 'Paid')

-- Testing values across table columns
CONSTRAINT sale_check CHECK (sale_price < retail_price)



-- Listing 7.8 (The UNIQUE Constraint -allows for null values in a column)
CREATE TABLE unique_constraint_example (
 contact_id bigserial CONSTRAINT contact_id_key PRIMARY KEY, --surrogate
 first_name varchar(50),
 last_name varchar(50),
 email varchar(200),
 CONSTRAINT email_unique UNIQUE (email) 
);

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Samantha', 'Lee', 'slee@example.org');
INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Betty', 'Diaz', 'bdiaz@example.org');
INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Sasha', 'Lee', 'slee@example.org'); --error: duplicate email violates unique constraint



-- Listing 7.9 (The NOT NULL Constraint)
CREATE TABLE not_null_example (
 student_id bigserial,
 first_name varchar(50) NOT NULL,
 last_name varchar(50) NOT NULL,
 CONSTRAINT student_id_key PRIMARY KEY (student_id)
);


-- Listing 7.10 (Removing Constraints)
ALTER TABLE not_null_example DROP CONSTRAINT student_id_key;
ALTER TABLE not_null_example ADD CONSTRAINT student_id_key PRIMARY KEY (student_id);
ALTER TABLE not_null_example ALTER COLUMN first_name DROP NOT NULL;
ALTER TABLE not_null_example ALTER COLUMN first_name SET NOT NULL;


-- Listing 7.11 (Importing NYC Address Data)
CREATE TABLE new_york_addresses (
 longitude numeric(9,6), 
 latitude numeric(9,6),
 street_number varchar(10), 
 street varchar(32), 
 unit varchar(7), 
 postcode varchar(5), 
 id integer CONSTRAINT new_york_key PRIMARY KEY
);
COPY new_york_addresses
FROM 'C:\SQL\city_of_new_york.csv'
WITH (FORMAT CSV, HEADER);


-- Listing 7.12 (Benchmark Queries for Index Performance)
-- EXPLAIN command provides output that lists the query plan for a specific database query
-- This might include how the data base plans to scan the table, whether or not it will use indexes
-- We add the ANALYZE keyword, EXPLAIN will carry out the query and show the actual execution time
EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY'; --execution time: 669.574ms vs 45.007ms
EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET'; --execution time: 328.261ms vs 9.137ms
EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';--execution time: 486.548ms vs 0.263ms

-- Instead of showing the query results, these key words tell the database to execute the query and display statistics about the 
-- query process and how long it took to execute.


-- Listing 7.13 (Creating B-Tree Index on NYC addresses table)
CREATE INDEX street_idx ON new_york_addresses (street);