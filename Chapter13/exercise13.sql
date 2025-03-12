-- 1)
-- a) 
replace(string, from, to)

i.e.
SELECT replace('Alvarez, Jr.', ', ', ' ');
SELECT replace('Williams, Sr.', ', ', ' ');

-- b)
-- A regular expression can work 
e.g.
SELECT regexp_replace('Alvarez, Jr.', ',\s', ' ');
SELECT regexp_replace('Williams, Sr.', ',\s', ' ');


-- c)
SELECT substring('Alvarez, Jr', '\s(\w+)')
SELECT substring('Williams, Sr', '\s(\w+)')


-- 2)
regexp_split_to_table(string, pattern) 
-- TODO (REVISIT)
WITH
    word_list (word)
AS
    (
        SELECT regexp_split_to_table(speech_text, '\s') AS word
        FROM president_speeches
        WHERE speech_date = '1974-01-30'
    )

SELECT lower(
               replace(replace(replace(word, ',', ''), '.', ''), ':', '')
             ) AS cleaned_word,
       count(*)
FROM word_list
WHERE length(word) >= 5
GROUP BY cleaned_word
ORDER BY count(*) DESC;



-- 3)
SELECT president,
 speech_date,
 ts_rank(search_speech_text,
 to_tsquery('war & security & threat & enemy')) AS ts_rank_score,
 ts_rank_cd(search_speech_text,
 to_tsquery('war & security & threat & enemy')) AS ts_rank_cd_score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY ts_rank_score DESC
LIMIT 5