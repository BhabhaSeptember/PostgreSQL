-- Listing 8.1 ( Creating and filling the 2014 Public Libraries Survey table)

CREATE TABLE pls_fy2014_pupld14a (
    stabr varchar(2) NOT NULL,
    fscskey varchar(6) CONSTRAINT fscskey2014_key PRIMARY KEY, --natural primary key
    libid varchar(20) NOT NULL,
    libname varchar(100) NOT NULL,
    obereg varchar(2) NOT NULL,
    rstatus integer NOT NULL,
    statstru varchar(2) NOT NULL,
    statname varchar(2) NOT NULL,
    stataddr varchar(2) NOT NULL,
    longitud numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    fipsst varchar(2) NOT NULL,
    fipsco varchar(3) NOT NULL,
    address varchar(35) NOT NULL,
    city varchar(20) NOT NULL,
    zip varchar(5) NOT NULL,
    zip4 varchar(4) NOT NULL,
    cnty varchar(20) NOT NULL,
    phone varchar(10) NOT NULL,
    c_relatn varchar(2) NOT NULL,
    c_legbas varchar(2) NOT NULL,
    c_admin varchar(2) NOT NULL,
    geocode varchar(3) NOT NULL,
    lsabound varchar(1) NOT NULL,
    startdat varchar(10), --varchar instead of date because csv file contains non-date values
    enddate varchar(10),--varchar instead of date because csv file contains non-date values
    popu_lsa integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    master numeric(8,2) NOT NULL,
    libraria numeric(8,2) NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    locgvt integer NOT NULL,
    stgvt integer NOT NULL,
    fedgvt integer NOT NULL,
    totincm integer NOT NULL,
    salaries integer,
    benefit integer,
    staffexp integer,
    prmatexp integer NOT NULL,
    elmatexp integer NOT NULL,
    totexpco integer NOT NULL,
    totopexp integer NOT NULL,
    lcap_rev integer NOT NULL,
    scap_rev integer NOT NULL,
    fcap_rev integer NOT NULL,
    cap_rev integer NOT NULL,
    capital integer NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio_ph integer NOT NULL,
    audio_dl float NOT NULL,
    video_ph integer NOT NULL,
    video_dl float NOT NULL,
    databases integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    referenc integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    elmatcir integer NOT NULL,
    loanto integer NOT NULL,
    loanfm integer NOT NULL,
    totpro integer NOT NULL,
    totatten integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    wifisess integer NOT NULL,
    yr_sub integer NOT NULL
);

--adding indexes to cols we will use for queries
--syntax = CREATE INDEX index_name ON table_name (column_name)
CREATE INDEX libname2014_idx ON pls_fy2014_pupld14a (libname);
CREATE INDEX stabr2014_idx ON pls_fy2014_pupld14a (stabr);
CREATE INDEX city2014_idx ON pls_fy2014_pupld14a (city);
CREATE INDEX visits2014_idx ON pls_fy2014_pupld14a (visits);

COPY pls_fy2014_pupld14a
FROM 'C:\SQL\pls_fy2014_pupld14a.csv'
WITH (FORMAT CSV, HEADER);



-- Listing 8.2 ( Creating and filling the 2009 Public Libraries Survey table)
CREATE TABLE pls_fy2009_pupld09a (
    stabr varchar(2) NOT NULL,
    fscskey varchar(6) CONSTRAINT fscskey2009_key PRIMARY KEY,
    libid varchar(20) NOT NULL,
    libname varchar(100) NOT NULL,
    address varchar(35) NOT NULL,
    city varchar(20) NOT NULL,
    zip varchar(5) NOT NULL,
    zip4 varchar(4) NOT NULL,
    cnty varchar(20) NOT NULL,
    phone varchar(10) NOT NULL,
    c_relatn varchar(2) NOT NULL,
    c_legbas varchar(2) NOT NULL,
    c_admin varchar(2) NOT NULL,
    geocode varchar(3) NOT NULL,
    lsabound varchar(1) NOT NULL,
    startdat varchar(10),
    enddate varchar(10),
    popu_lsa integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    master numeric(8,2) NOT NULL,
    libraria numeric(8,2) NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    locgvt integer NOT NULL,
    stgvt integer NOT NULL,
    fedgvt integer NOT NULL,
    totincm integer NOT NULL,
    salaries integer,
    benefit integer,
    staffexp integer,
    prmatexp integer NOT NULL,
    elmatexp integer NOT NULL,
    totexpco integer NOT NULL,
    totopexp integer NOT NULL,
    lcap_rev integer NOT NULL,
    scap_rev integer NOT NULL,
    fcap_rev integer NOT NULL,
    cap_rev integer NOT NULL,
    capital integer NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio integer NOT NULL,
    video integer NOT NULL,
    databases integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    referenc integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    loanto integer NOT NULL,
    loanfm integer NOT NULL,
    totpro integer NOT NULL,
    totatten integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    yr_sub integer NOT NULL,
    obereg varchar(2) NOT NULL,
    rstatus integer NOT NULL,
    statstru varchar(2) NOT NULL,
    statname varchar(2) NOT NULL,
    stataddr varchar(2) NOT NULL,
    longitud numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    fipsst varchar(2) NOT NULL,
    fipsco varchar(3) NOT NULL
);

CREATE INDEX libname2009_idx ON pls_fy2009_pupld09a (libname);
CREATE INDEX stabr2009_idx ON pls_fy2009_pupld09a (stabr);
CREATE INDEX city2009_idx ON pls_fy2009_pupld09a (city);
CREATE INDEX visits2009_idx ON pls_fy2009_pupld09a (visits);

COPY pls_fy2009_pupld09a
FROM 'C:\SQL\pls_fy2009_pupld09a.csv'
WITH (FORMAT CSV, HEADER);



-- Listing 8.3 (Counting Rows and Values Using coount() Aggregate Function)
--count(*) includes NULL values
SELECT count(*)
FROM pls_fy2014_pupld14a;
SELECT count(*)
FROM pls_fy2009_pupld09a;



-- Listing 8.4 (Counting Values Present in a Column)
SELECT count(salaries)
FROM pls_fy2014_pupld14a;

-- Listing 8.5 (Counting Distinct Values in a Column)
SELECT count(libname)
FROM pls_fy2014_pupld14a;
SELECT count(DISTINCT libname)
FROM pls_fy2014_pupld14a;

-- Listing 8.6 (Findig Max and Min Values)
SELECT max(visits), min(visits)
FROM pls_fy2014_pupld14a;


-- Listing 8.7 (Aggregating Data Using GROUP BY)
SELECT stabr
FROM pls_fy2014_pupld14a
GROUP BY stabr --col name to group by , results will have no duplicates
ORDER BY stabr; --grouped results will be in alphabetical order


-- Listing 8.8 (Using GROUP BY on multiple columns)
--show unique combinations of city & stabr col
SELECT city, stabr
FROM pls_fy2014_pupld14a
GROUP BY city, stabr
ORDER BY city, stabr;


-- Listing 8.9 (Combining GROUP BY with count() Aggregate)
SELECT stabr, count(*) 
FROM pls_fy2014_pupld14a
GROUP BY stabr --must include GROUP BY when selecting column with aggregate function
ORDER BY count(*) DESC;



-- Listing 8.10 (Using GROUP BY on Multiple Columns with count() aggregate)
 SELECT stabr, stataddr, count(*) 
 FROM pls_fy2014_pupld14
 GROUP BY stabr, stataddr --count() shows the number of unique combinations
 ORDER BY stabr ASC, count(*) DESC;

--  Listing 8.11 (Using The sum() Aggregate Function To Total Visits To Libraries in 2014 and 2009)
SELECT sum(visits) AS visits_2014
FROM pls_fy2014_pupld14a
WHERE visits >= 0; 

SELECT sum(visits) AS visits_2009
FROM pls_fy2009_pupld09a
WHERE visits >= 0;


-- Listing 8.12 (Using The sum() Aggregate Function To Total Visits On Joined 2014 And 2009 Library Tables)
SELECT sum(pls14.visits) AS visits_2014,
 sum(pls09.visits) AS visits_2009
 FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
 ON pls14.fscskey = pls09.fscskey
 WHERE pls14.visits >= 0 AND pls09.visits >= 0;


--  Listing 8.13 (Using GROUP BY To Track Percent Change In Library Visits By State)
SELECT pls14.stabr,
 sum(pls14.visits) AS visits_2014,
 sum(pls09.visits) AS visits_2009,
 round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) /
 sum(pls09.visits) * 100, 2 ) AS pct_change
 FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.stabr
ORDER BY pct_change DESC;

-- Listing 8.14 (Filtering an Aggregate Query Using HAVING)
SELECT pls14.stabr,
 sum(pls14.visits) AS visits_2014,
 sum(pls09.visits) AS visits_2009,
 round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) /
 sum(pls09.visits) * 100, 2 ) AS pct_change
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.stabr
HAVING sum(pls14.visits) > 50000000
ORDER BY pct_change DESC;