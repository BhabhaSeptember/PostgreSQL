-- This script was generated by the ERD tool in pgAdmin 4.
-- Please log an issue at https://redmine.postgresql.org/projects/pgadmin4/issues/new if you find any bugs, including reproduction steps.
BEGIN;


CREATE TABLE IF NOT EXISTS public.products_menu
(
    product_id bigserial,
    name character varying(50),
    price numeric(8, 2),
    PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS public.cart
(
    product_id integer,
    qty integer,
    PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS public.order_header
(
    order_id bigserial,
    user_id integer,
    order_date timestamp with time zone,
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS public.order_details
(
    order_id integer,
    product_id integer,
    qty integer
);

CREATE TABLE IF NOT EXISTS public.users
(
    user_id bigserial,
    username character varying(50),
    PRIMARY KEY (user_id)
);

ALTER TABLE IF EXISTS public.cart
    ADD FOREIGN KEY (product_id)
    REFERENCES public.products_menu (product_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.order_header
    ADD FOREIGN KEY (user_id)
    REFERENCES public.users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.order_details
    ADD FOREIGN KEY (order_id)
    REFERENCES public.order_header (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.order_details
    ADD FOREIGN KEY (product_id)
    REFERENCES public.products_menu (product_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;

-- ============================================== INSERT STATEMENTS ============================================== 

INSERT INTO products_menu (name, price)
VALUES 
('Golf T-shirt', '159.99'),
('Sweatpants', '250.00'),
('Maxi-dress', '329.99'),
('Tennis Shoes', '1299.99'), 
('Gold watch', '59000'),
('Earings', '200.00'),
('Jersey', '500.00');
SELECT * FROM products_menu;


INSERT INTO users (username)
VALUES 
('Frank'),
('Bandile'),
('Caleb'),
('Susan'),
('Trish'),
('Halle'),
('Beryl');
SELECT * FROM users;


-- ======================================================= QUERIES ======================================================= 


-- ============================================= CHECKOUT / SHOPPING SIMULATION ======================================================= 

-- ===== DEMO =====
-- USER 
-- adding to cart
-- DO $$
-- BEGIN
-- IF EXISTS ( SELECT * FROM cart WHERE product_id = 5) THEN 
-- UPDATE cart SET qty = qty + 1 WHERE product_id = 5;
-- ELSE 
-- INSERT INTO cart(product_id, qty) VALUES(5, 2);
-- END IF;
-- END $$
-- SELECT * FROM cart

CREATE OR REPLACE FUNCTION add_to_cart(p_product_id INT, p_qty INT) 
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT * FROM cart WHERE product_id = p_product_id) THEN 
        UPDATE cart SET qty = qty + p_qty WHERE product_id = p_product_id;
    ELSE 
        INSERT INTO cart(product_id, qty) VALUES(p_product_id, p_qty);
    END IF;
END;
$$ LANGUAGE plpgsql;



SELECT 
cart.product_id,
p_m.name,
p_m.price AS unit_price,
cart.qty
FROM cart AS cart
JOIN products_menu AS p_m
ON cart.product_id = p_m.product_id;


-- deleting from cart
DO $$
BEGIN
IF EXISTS ( SELECT * FROM cart WHERE product_id = 5 AND qty > 1) THEN 
UPDATE cart SET qty = qty - 1 WHERE product_id = 5;
ELSE 
DELETE  FROM cart WHERE product_id = 5;
END IF;
END $$
SELECT * FROM cart

SELECT 
cart.product_id,
p_m.name,
p_m.price,
cart.qty
FROM cart AS cart
JOIN products_menu AS p_m
ON cart.product_id = p_m.product_id;


-- checkout
INSERT INTO order_header(user_id, order_date)
VALUES 
(3, now());
SELECT * FROM order_header;

SELECT 
o_h.order_id,
o_h.user_id,
users.username,
o_h.order_date
FROM order_header AS o_h JOIN users ON o_h.user_id = users.user_id


INSERT INTO order_details(order_id, product_id, qty)
SELECT
(SELECT MAX(order_id) FROM order_header), product_id, qty 
FROM cart;
DELETE FROM cart;
SELECT * FROM cart

-- single order
SELECT 
o_d.order_id,
users.username,
p_m.name AS item,
o_d.qty,
p_m.price AS unit_price,
o_h.order_date
FROM order_details AS o_d JOIN order_header AS o_h ON o_d.order_id = o_h.order_id
JOIN users ON users.user_id = o_h.user_id
JOIN products_menu AS p_m ON p_m.product_id = o_d.product_id
WHERE o_d.order_id = 3;

-- multiple/all orders
SELECT 
o_d.order_id,
users.username,
p_m.name AS item,
o_d.qty,
p_m.price AS unit_price,
o_h.order_date
FROM order_details AS o_d JOIN order_header AS o_h ON o_d.order_id = o_h.order_id
JOIN users ON users.user_id = o_h.user_id
JOIN products_menu AS p_m ON p_m.product_id = o_d.product_id



