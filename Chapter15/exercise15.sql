-- 1)
CREATE OR REPLACE VIEW nyc_taxi_trips_per_hr AS
SELECT date_part('hour', tpep_pickup_datetime) AS trip_hour, 
count(*) 
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY trip_hour
ORDER BY trip_hour;

-- 2)
-- Relates to Chapter10 (Can revisit)

-- 3)

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN inspection_date date;
 UPDATE meat_poultry_egg_inspect AS inspect
 SET inspection_date = '2019-12-01'
 WHERE EXISTS (SELECT state_regions.region 
 FROM state_regions 
 WHERE inspect.st = state_regions.st 
 AND state_regions.region = 'New England');

-- table

--  function
 CREATE OR REPLACE FUNCTION add_inspection_date()
 RETURNS trigger AS
 $$
 BEGIN
  IF NEW.grade <> OLD.grade THEN
    INSERT INTO grades_history (
        student_id,
        course_id,
        change_time,
        course,
        old_grade,
        new_grade)
    VALUES
        (OLD.student_id,
         OLD.course_id,
         now(),
         OLD.course,
          OLD.grade,
           NEW.grade);
         END IF;
         RETURN NEW;
 END;
 $$ LANGUAGE plpgsql;


-- trigger


