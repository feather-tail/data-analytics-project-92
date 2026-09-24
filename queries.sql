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


-- Считает количество покупателей в каждой возрастной группе
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 THEN '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
WHERE age >= 16
GROUP BY age_category
ORDER BY age_category;


-- Считает количество уникальных покупателей и выручку по каждому месяцу
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY selling_month;


-- Находит покупателей, первая покупка которых была акционной
WITH first_sales AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date, s.sales_id
        ) AS row_number
    FROM sales AS s
)
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    fs.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_sales AS fs
INNER JOIN customers AS c
    ON fs.customer_id = c.customer_id
INNER JOIN employees AS e
    ON fs.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON fs.product_id = p.product_id
WHERE
    fs.row_number = 1
    AND p.price = 0
ORDER BY fs.customer_id;