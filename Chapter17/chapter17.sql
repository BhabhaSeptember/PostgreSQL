-- Listing 17.1 (Creating a Table to Test Vacumming)
CREATE TABLE vacuum_test (
    integer_column integer
);


-- Listing 17.2 (Determinining Size of vacuum_test Table)
SELECT pg_size_pretty(
    pg_total_relation_size('vacuum_test')
);


-- Listing 17.3 (Inserting rows into table)
INSERT INTO vacuum_test
SELECT * FROM generate_series(1, 500000); -- from 1 to 500_000


-- Listing 17.4 (Updating All Rows in table)
UPDATE vacuum_test
SET integer_column = integer_column + 1;


-- Listing 17.5 (Updating All Rows in table)
SELECT relname,
last_vacuum,
last_autovacuum,
vacuum_count
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';


-- Listing 17.6 (Manual VACUUM)
VACUUM vacuum_test;


-- Listing 17.7 (Manual VACUUM FULL to Reclaim Disk Space)
VACUUM FULL vacuum_test;


-- Listing 17.8 (Showing location of postgresql.conf file in PC)
SHOW config_file;


-- Listing 17.9 (Sample postgresql.conf Settings)
datestyle = 'iso, mdy';
timezone = 'Africa/Johannesburg';
default_text_search_config = 'pg_catalog.english';

--reloading settings with pg_ctl 
pg_ctl reload -D "C:\path\to\data\directory\";
e.g. pg_ctl reload -D "C:\Program Files\PostgreSQL\16\data";







