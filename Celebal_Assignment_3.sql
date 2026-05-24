CREATE DATABASE superstore_db;
USE superstore_db;
show tables;

RENAME TABLE `sample - superstore` TO superstore_raw;

SELECT * FROM superstore_raw
LIMIT 10;

ALTER TABLE superstore_raw
CHANGE `Row ID` row_id INT;

ALTER TABLE superstore_raw
CHANGE `Order ID` order_id VARCHAR(50);

ALTER TABLE superstore_raw
MODIFY `Order Date` VARCHAR(20);

ALTER TABLE superstore_raw
MODIFY `Ship Date` VARCHAR(20);
UPDATE superstore_raw
SET `Order Date` = STR_TO_DATE(`Order Date`, '%m/%d/%Y');
UPDATE superstore_raw
SET `Ship Date` = STR_TO_DATE(`Ship Date`, '%m/%d/%Y');

ALTER TABLE superstore_raw
MODIFY `Order Date` DATE;

ALTER TABLE superstore_raw
CHANGE `Order Date` order_date DATE;

ALTER TABLE superstore_raw
MODIFY `Ship Date` DATE;

ALTER TABLE superstore_raw
CHANGE `Ship Date` ship_date DATE;

ALTER TABLE superstore_raw
CHANGE `Customer ID` customer_id VARCHAR(50);

ALTER TABLE superstore_raw
CHANGE `Customer Name` customer_name VARCHAR(100);

ALTER TABLE superstore_raw
CHANGE `Postal Code` postal_code INT;

ALTER TABLE superstore_raw
CHANGE `Product ID` product_id VARCHAR(50);

ALTER TABLE superstore_raw
CHANGE `Sub-Category` sub_category VARCHAR(100);

ALTER TABLE superstore_raw
CHANGE `Product Name` product_name VARCHAR(255);

ALTER TABLE superstore_raw
CHANGE `Ship Mode` ship_mode VARCHAR(50);

DESCRIBE superstore_raw;

CREATE TABLE customers AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region
FROM superstore_raw;

CREATE TABLE products AS
SELECT DISTINCT
    product_id,
    category,
    sub_category,
    product_name
FROM superstore_raw;

CREATE TABLE orders AS
SELECT DISTINCT
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
FROM superstore_raw;

show tables;

select * from orders;

select * from customers;

-- 5. Subquery: Customers with Above Average Sales
SELECT
    customer_id,
    SUM(sales) AS total_sales
FROM orders
GROUP BY customer_id
HAVING SUM(sales) >
(
    SELECT AVG(total_sales)
    FROM
    (
        SELECT
            customer_id,
            SUM(sales) AS total_sales
        FROM orders
        GROUP BY customer_id
    ) avg_sales
);

-- 6. Subquery: Highest Order Per Customer 
SELECT *
FROM orders o
WHERE sales =
(
    SELECT MAX(sales)
    FROM orders
    WHERE customer_id = o.customer_id
);

-- 7. CTE: Total Sales Per Customer
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)

SELECT *
FROM customer_sales
ORDER BY total_sales DESC;

--  8. Window Function: ROW_NUMBER()
SELECT
    customer_id,
    sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY sales DESC
    ) AS row_num
FROM orders;

-- 9. Window Function: RANK()
SELECT
    customer_id,
    SUM(sales) AS total_sales,
    RANK() OVER
    (
        ORDER BY SUM(sales) DESC
    ) AS sales_rank
FROM orders
GROUP BY customer_id;



WITH customer_total_sales AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.sales) AS total_sales
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)

SELECT
    customer_id,
    customer_name,
    total_sales,
    RANK() OVER
    (
        ORDER BY total_sales DESC
    ) AS customer_rank
FROM customer_total_sales;

-- 11. Business Query: Top 10 Customers 
SELECT
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC
LIMIT 10;


-- 12. Business Query: Low Performing Customers 
SELECT
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING SUM(o.sales) < 500
ORDER BY total_sales;

-- 13. Business Query: Single-Order Customers
SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) = 1;


-- Business Query: Orders Above Average Sales
SELECT *
FROM orders
WHERE sales >
(
    SELECT AVG(sales)
    FROM orders
);