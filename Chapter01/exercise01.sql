CREATE TABLE zoo_animals_collection (
	id bigserial,
	animal varchar(25),
	quantity numeric	
);

INSERT INTO zoo_animals_collection (animal, quantity)
VALUES('Giraffe', 2),
('Rhinoceros', 2),
('Elephant', 2);

-- Error simulation: 
-- ERROR:  syntax error at or near "2"
-- LINE 2: VALUES('Hippo' 2),
INSERT INTO zoo_animals_collection (animal, quantity)
VALUES('Hippo' 2),

SELECT * FROM zoo_animals_collection



CREATE TABLE zoo_animals_specs (
	id bigserial,
	name varchar(25),
	animal varchar(25),
	scientific_name varchar(50),
	sex char(1),
	birth_date date
);

INSERT INTO zoo_animals_specs (name, animal, scientific_name, sex, birth_date)
VALUES ('Godfrey', 'Giraffe', 'Giraffa camelopardalis', 'M', '2020-03-25'),
('Gina', 'Giraffe', 'Giraffa camelopardalis', 'F', '2018-05-16'),
('Rico', 'Rhinoceros', 'Rhinocerotidae', 'M', '2020-03-25'),
('Rose', 'Rhinoceros', 'Rhinocerotidae', 'F', '2018-05-16'),
('Errol', 'Elephant', 'Elephantidae', 'M', '2020-03-25'),
('Emily', 'Elephant', 'Elephantidae', 'F', '2018-05-16');


SELECT * FROM zoo_animals_specs