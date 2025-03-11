-- FORMATTING TEXT USING STRING FUNCTIONS
-- CASE FORMATTING
upper(string)
e.g. upper('Neal7') = Neal7


lower(string)
e.g. lower('Randy') = randy


initcap(string)
e.g. initcap('at the end of the day') = At The End Of The day


-- CHARACTER INFORMATION
char_length(string)
e.g. char_length(' Pat ') = 5


length(string)
e.g. length('hello Bhabha') = 12


position(substring in string)
e.g. position(', ' in 'Tan, Bella') = 4


-- REMOVING CHARACTERS
trim(characters from string)
e.g. trim('s' from 'socks') = ock
     trim(trailing 's' from 'socks') = socks
     trim(leading 's' from 'socks') = ocks
     trim(both 's' from 'suspects') = uspect
     trim(' Pat ') = Pat --removes spaces


ltrim(string, characters)
e.g. ltrim('socks', 's') = ocks
     rtrim('socks', 's') = sock



-- EXTRACTING AND REPLACING CHARACTERS
left(string, number)
e.g. left('703-555-1212', 3) = 703

right(string, number)
e.g. right('703-555-1212', 8) = 555-1212

replace(string, from, to)
e.g. replace('bat', 'b', 'c') = cat


-- REGULAR EXPRESSIONS
substring(string from pattern)
e.g. 
substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{4}') = 2019


-- Listing 13.1 (Crime Report Text)
 4/16/17-4/17/17
2100-0900 hrs.
46000 Block Ashmere Sq.
 Sterling
 Larceny: The victim reported that a
bicycle was stolen from their opened
garage door during the overnight hours.
C0170006614

04/10/17
1605 hrs.
21800 block Newlin Mill Rd.
Middleburg
Larceny: A license plate was reported
stolen from a vehicle.
SO170006250



-- Listing 13.2 (Creating & Loading The crime_reports Table)
CREATE TABLE crime_reports (
 crime_id bigserial PRIMARY KEY,
 date_1 timestamp with time zone,
 date_2 timestamp with time zone,
 street varchar(250),
 city varchar(100),
 crime_type varchar(100),
 description text,
 case_number varchar(50),
 original_text text NOT NULL
);
COPY crime_reports (original_text)
FROM 'C:\SQL\crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');



-- Listing 13.3 (Using regexp_match() To Find First Date)
-- returns first match
SELECT crime_id,
 regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;



-- Listing 13.4 (Using regexp_matches() Function With 'g' Flag)
-- 'g' flag returns all matches not just the first one
SELECT crime_id,
 regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
 FROM crime_reports;



-- Listing 13.5 (Using regexp_match() To Find Second Date)
SELECT crime_id,
 regexp_match(original_text, '-\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;


-- Listing 13.6 (Using Capture Group To Return Only The Date)
SELECT crime_id,
 regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
FROM crime_reports;



-- Listing 13.7 (Matching Case Number, Date, Crime Type & City)
SELECT 
 regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number,
 regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
 regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
 regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n') AS city
FROM crime_reports;



-- Listing 13.8 (Retrieving Value From Within Array)
-- [1] represents first element in array
SELECT 
 crime_id,
(regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1]
AS case_number
FROM crime_reports;



-- Listing 13.9 (Updating crime_reports date_1 Column)
-- TODO (REVISIT)
-- '||' = concatenation operator
UPDATE crime_reports
 SET date_1 =
(
 (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] 
 || ' ' ||          
 (regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] 
  ||' US/Eastern'
 )::timestamptz;
SELECT crime_id,
 date_1,
 original_text
FROM crime_reports;




-- Listing 13.10 (Updating All crime_reports Columns)
UPDATE crime_reports
SET date_1 = 
 (
 (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1]
 || ' ' ||
 (regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] 
 ||' US/Eastern'
 )::timestamptz,
 
date_2 = 
  CASE
    WHEN (regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})') IS NULL)
      AND (regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL)
    THEN (
      TO_CHAR(TO_DATE((regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1], 'MM/DD/YY'), 'YYYY-MM-DD')
      || ' ' ||
      LPAD((regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1], 4, '0')  -- Ensure time is 4 digits
      || ' US/Eastern'
    )::timestamptz

    WHEN (regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})') IS NOT NULL)
      AND (regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL)
    THEN (
      TO_CHAR(TO_DATE((regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})'))[1], 'MM/DD/YY'), 'YYYY-MM-DD')
      || ' ' ||
      LPAD((regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1], 4, '0')  -- Ensure time is 4 digits
      || ' US/Eastern'
    )::timestamptz

    ELSE NULL
  END,
 street = (regexp_match(original_text, 'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))'))[1],
 city = (regexp_match(original_text,
 '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n'))[1],
 crime_type = (regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):'))[1],
 description = (regexp_match(original_text, ':\s(.+)(?:C0|SO)'))[1],
 case_number = (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1];



-- Listing 13.11 (Viewing Selected Crime Data)
SELECT date_1,
 street,
 city,
 crime_type
FROM crime_reports;


-- Listing 13.12 ()
-- Listing 13.13 ()
-- Listing 13.14 ()
-- Listing 13.15 ()
-- Listing 13.16 ()
-- Listing 13.17 ()
-- Listing 13.18 ()
-- Listing 13.19 ()
-- Listing 13.20 ()
-- Listing 13.21 ()
-- Listing 13.22 ()
-- Listing 13.23 ()
-- Listing 13.24 ()
-- Listing 13.25 ()
-- Listing 13.26 ()
