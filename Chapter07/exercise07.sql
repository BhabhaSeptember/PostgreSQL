-- 1)
CREATE TABLE albums (
 album_id bigserial PRIMARY KEY,
 album_catalog_code varchar(100) NOT NULL,
 album_title text NOT NULL,
 album_artist text NOT NULL,
 album_release_date date,
 album_genre varchar(40),
 album_description text
);


CREATE TABLE songs (
 song_id bigserial PRIMARY KEY,
 song_title text NOT NULL,
 song_artist text NOT NULL,
 album_id bigint REFERENCES albums (album_id)
);

-- album_id and song_id will be our surrogate primary key's to ensure a unique identifier for each album and song in the respective tables
-- we then use album_id as a foreign key in the songs table so we can relate both tables for future queries
-- we also want to ensure that we have title and artist names for each album and song for the database to produce useful information
-- the catalog code must also not be null for identification purposes in queries

-- 2) album_catalog_code is a good choice as long as the value is kept unique for each album
--  Our NOT NULL constraint will ensure no empty values so it will satisfy the conditions for primary keys

-- 3) Foreign key in songs table "album_id" should get an index to speed up queries when we perform JOIN queries
-- Any column that can be used for queries can also get indexes for example:
-- title, artist, genre and release date 
