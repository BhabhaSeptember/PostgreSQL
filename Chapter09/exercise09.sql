-- 1)
ALTER TABLE  meat_poultry_egg_inspect ADD COLUMN meat_processing boolean;
ALTER TABLE  meat_poultry_egg_inspect ADD COLUMN poultry_processing boolean;


-- 2)
UPDATE meat_poultry_egg_inspect
SET meat_processing = true
WHERE activities ILIKE  '%meat processing%' 

UPDATE meat_poultry_egg_inspect
SET poultry_processing = true
WHERE activities ILIKE  '%poultry processing%' 

 SELECT activities, meat_processing, poultry_processing 
 FROM meat_poultry_egg_inspect

-- 3)
-- a)
SELECT 
count(meat_processing) AS meat_processing_count,
count(poultry_processing) AS poultry_processing_count
FROM meat_poultry_egg_inspect

-- b)
SELECT count(*) AS meat_poultry_processing_count
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE AND
      poultry_processing = TRUE;