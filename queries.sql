-- Считает общее количество покупателей в таблице customers
SELECT COUNT(*) AS customers_count
FROM customers;


-- Выводит 10 продавцов с наибольшей суммарной выручкой
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY income DESC
LIMIT 10;


-- Выводит продавцов, чья средняя выручка за сделку ниже средней по всем сделкам
WITH seller_average AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        AVG(s.quantity * p.price) AS average_income
    FROM sales AS s
    INNER JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    INNER JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY
        e.employee_id,
        e.first_name,
        e.last_name
),
total_average AS (
    SELECT
        AVG(s.quantity * p.price) AS average_income
    FROM sales AS s
    INNER JOIN products AS p
        ON s.product_id = p.product_id
)
SELECT
    sa.seller,
    FLOOR(sa.average_income) AS average_income
FROM seller_average AS sa
CROSS JOIN total_average AS ta
WHERE sa.average_income < ta.average_income
ORDER BY average_income ASC;


-- Выводит суммарную выручку каждого продавца по дням недели
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    LOWER(TO_CHAR(s.sale_date, 'FMDay')) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    EXTRACT(ISODOW FROM s.sale_date),
    LOWER(TO_CHAR(s.sale_date, 'FMDay'))
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date),
    seller;