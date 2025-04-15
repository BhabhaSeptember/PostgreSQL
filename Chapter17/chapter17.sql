-- Listing 17.1 (Creating a Table to Test Vacumming)
CREATE TABLE vacuum_test (
    integer_column integer
);
DROP TABLE vacuum_test;
SELECT * FROM vacuum_test;


-- Listing 17.2 (Determinining Size of vacuum_test Table)
SELECT pg_size_pretty(
    pg_total_relation_size('vacuum_test')
);


-- Listing 17.3 (Inserting rows into table)
INSERT INTO vacuum_test
SELECT * FROM generate_series(1, 500000); -- from 1 to 500_000

SELECT pg_size_pretty(
    pg_total_relation_size('vacuum_test')
);

-- Listing 17.4 (Updating All Rows in table)
UPDATE vacuum_test
SET integer_column = integer_column + 1;

SELECT pg_size_pretty(
    pg_total_relation_size('vacuum_test')
);


-- Listing 17.5 (Viewing autovacuum Stats For vacuum_test Table)
SELECT relname,
last_vacuum,
last_autovacuum,
vacuum_count
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';


-- Listing 17.6 (Manual VACUUM)
VACUUM vacuum_test;

SELECT pg_size_pretty(
    pg_total_relation_size('vacuum_test')
);

SELECT relname,
last_vacuum,
last_autovacuum,
vacuum_count
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- Listing 17.7 (Manual VACUUM FULL to Reclaim Disk Space)
VACUUM FULL vacuum_test;

SELECT pg_size_pretty(
    pg_total_relation_size('vacuum_test')
);

-- Listing 17.8 (Showing location of postgresql.conf file in PC)
SHOW config_file;


-- Listing 17.9 (Sample Of postgresql.conf Settings)
datestyle = 'iso, mdy';
timezone = 'Africa/Johannesburg';
default_text_search_config = 'pg_catalog.english';

-- Listing 17.10 (Reloading Settings With pg_ctl)
-- first to find location of data directory:
SHOW data_directory


-- Below commands to be run in command line prompt
--reloading settings with pg_ctl 
syntax: pg_ctl reload -D "C:\path\to\data\directory\";

pg_ctl reload -D "C:\Program Files\PostgreSQL\16\data";


-- Listing 17.11(Backing up analysis databse with pg_dump)
 pg_dump -d analysis -U postgres -Fc > analysis_backup.sql


-- backing up a table:
 pg_dump -t train_rides -d analysis -U postgres -Fc > train_backup.sql


-- Listing 17.12 (Restoring analysis database with pg_restore)
 pg_restore -C -d postgres -U postgres analysis_backup.sql


