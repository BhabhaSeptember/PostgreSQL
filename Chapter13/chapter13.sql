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
     trim(trailing 's' from 'socks') = sock
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



-- Listing 13.12 (Using Regular Expression In WHERE Clause)
-- tilde (~) = performs case sensitive match on some regex
-- tilde-asterix (~*) = case insensitive
-- '!~*' = not match regex that is case insensitive

SELECT geo_name
FROM us_counties_2010
 WHERE geo_name ~* '(.+lade.+|.+lare.+)'
ORDER BY geo_name;

-- below matches counties with 'ash' and excludes those starting with 'Wash'
SELECT geo_name
FROM us_counties_2010
 WHERE geo_name ~* '.+ash.+' AND geo_name !~ 'Wash.+'
ORDER BY geo_name;



-- Listing 13.13 (Additional Regex Functions)
regexp_replace(string, pattern, replacement_text)
e.g. SELECT regexp_replace('05/12/2018', '\d{4}', '2017');

regexp_split_to_table(string, pattern) 
--splits delimited text into rows at delimiter
e.g. SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',');

regexp_split_to_array(string, pattern)
-- splits delimited text into an array
 SELECT regexp_split_to_array('Phil Mike Tony Steve', ',');



-- Listing 13.14 (Finding Array Length)
-- '1' in second param refers to first dimension of array i.e. the first array 
-- [1, 2, 3][1, 2, 3] = 2 dimensional array example
SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);


-- TEXT SEARCH DATA TYPES
-- tsvector (reduces text to sorted list of lexemes) i.e. washes, washed, washing = wash
-- tsvector removes stop words e.g. 'I', 'the', 'it', 'am' etc
-- tsquery (represents search query terms & operators)
-- Listing 13.15 (Converting text To tsvector Data)
SELECT to_tsvector('I am walking across the sitting room to sit with you.');

-- Listing 13.16 (Converting Search Terms To tsquery Data)
-- tsquery represents full text search query, optimized with lexemes
SELECT to_tsquery('walking & sitting');



-- Listing 13.17 (Querying tsvector Type With tsquery)
-- @@ = match operator for searching
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & sitting');
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & running');




-- Listing 13.18 (Creating & Filling president_speeches Table)
CREATE TABLE president_speeches (
 sotu_id serial PRIMARY KEY,
 president varchar(100) NOT NULL,
 title varchar(250) NOT NULL,
 speech_date date NOT NULL,
 speech_text text NOT NULL,
 search_speech_text tsvector
);
COPY president_speeches (president, title, speech_date, speech_text)
FROM 'C:\SQL\sotu-1946-1977.csv'
WITH (FORMAT CSV, DELIMITER '|', HEADER OFF, QUOTE '@');



-- Listing 13.19 (Converting Speeches to tsvector In search_speech_text Column)
UPDATE president_speeches
 SET search_speech_text = to_tsvector('english', speech_text);



-- Listing 13.20 (Creating GIN index For Text Search)
-- GIN index contains entry for each lexeme and its location
CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);



-- Listing 13.21 (Finding Speeches Containing Word 'Vietnam')
SELECT president, speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam')
ORDER BY speech_date;



-- Listing 13.22 (Showing Search Result Locations)
-- ts_headline() function shows where search terms appear in text
-- param1 = original text column
-- param2 = word to highlight
-- param3 = list of optional formatting parameters
SELECT president,
 speech_date,
ts_headline(speech_text, to_tsquery('Vietnam'),
'StartSel = <, 
 StopSel = >,
 MinWords=5,
 MaxWords=7,
 MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam');



-- Listing 13.23 (Using Multiple Search Terms)
SELECT president, 
 speech_date,
 ts_headline(speech_text, to_tsquery('transportation & !roads'),
 'StartSel = <,
 StopSel = >,
 MinWords=5,
 MaxWords=7,
 MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('transportation & !roads');



-- Listing 13.24 (Searching For Adjacent Words)
-- (<->) = distance operator finds adjacent words i.e. military followed by defense (in variations of tenses)
-- e.g. (<2>) would return matches where terms are exactly two words apart i.e. "military and defense"
SELECT president,
 speech_date,
 ts_headline(speech_text, to_tsquery('military <-> defense'),
 'StartSel = <,
 StopSel = >,
 MinWords=5,
 MaxWords=7,
 MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <-> defense');



-- Listing 13.25 (Scoring Relevance With ts_rank())
-- ts_rank() = generates rank value based on how often lexemes appear in text
-- ts_rank_cd() = considers how close lexemes searched are close to each other
SELECT president,
 speech_date,
 ts_rank(search_speech_text,
 to_tsquery('war & security & threat & enemy')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5



-- Listing 13.26 (Normalizing ts_rank() by speech length)
-- the '2' in 3rd param of ts_rank() is normalization code
-- code 2 instructs function to divide score by length of data in column...
-- ...for reliable comparison between speeches of differing lengths
SELECT president,
 speech_date,
 ts_rank(search_speech_text,
 to_tsquery('war & security & threat & enemy'), 2)::numeric
 AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;



