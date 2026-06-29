CREATE DATABASE superstore;
USE superstore;
USE superstore;

CREATE TABLE superstore_sales (
    order_id VARCHAR(30),
    order_date DATE,
    ship_date DATE,
    customer VARCHAR(255),
    manufactory VARCHAR(255),
    product_name TEXT,
    segment VARCHAR(100),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    region VARCHAR(100),
    zip INT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    discount DECIMAL(5,2),
    profit DECIMAL(10,4),
    quantity INT,
    sales DECIMAL(10,3),
    profit_margin DECIMAL(10,4)
);

SHOW TABLES;

SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'pid_file';
SHOW VARIABLES LIKE 'datadir';

SHOW VARIABLES LIKE 'local_infile';

SELECT @@local_infile;

LOAD DATA LOCAL INFILE 'C:\Users\adith\Downloads\cleaned_sales_dataSet.csv'
INTO TABLE superstore_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, order_date, ship_date, customer, manufactory, product_name,
segment, category, subcategory, region, zip, city, state, country,
discount, profit, quantity, sales, profit_margin);

SELECT DATABASE();

LOAD DATA LOCAL INFILE 'C:\Users\adith\Downloads\cleaned_sales_dataSet.csv'
INTO TABLE superstore_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, order_date, ship_date, customer, manufactory, product_name,
segment, category, subcategory, region, zip, city, state, country,
discount, profit, quantity, sales, profit_margin);

SELECT @@local_infile;

SELECT customer,
       ROUND(SUM(sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY customer
ORDER BY Total_Sales DESC
LIMIT 10;

SELECT customer,
       ROUND(SUM(profit),2) AS Total_Profit
FROM superstore_sales
GROUP BY customer
ORDER BY Total_Profit DESC
LIMIT 10;

SELECT
MONTH(order_date) AS Month_No,
MONTHNAME(order_date) AS Month,
ROUND(SUM(sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY MONTH(order_date),MONTHNAME(order_date)
ORDER BY Month_No;

SELECT
YEAR(order_date) AS Year,
ROUND(SUM(sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY YEAR(order_date)
ORDER BY Year;

SELECT
MONTHNAME(order_date) AS Month,
ROUND(SUM(profit),2) AS Total_Profit
FROM superstore_sales
GROUP BY MONTH(order_date),MONTHNAME(order_date)
ORDER BY MONTH(order_date);

SELECT
category,
ROUND(AVG(discount),2) AS Avg_Discount
FROM superstore_sales
GROUP BY category;

SELECT
category,
ROUND(AVG(profit_margin),3) AS Avg_Profit_Margin
FROM superstore_sales
GROUP BY category
ORDER BY Avg_Profit_Margin DESC;

SELECT
order_id,
customer,
product_name,
sales,
profit
FROM superstore_sales
ORDER BY profit DESC
LIMIT 10;

SELECT
order_id,
customer,
product_name,
sales,
profit
FROM superstore_sales
ORDER BY profit ASC
LIMIT 10;

SELECT
segment,
ROUND(SUM(sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY segment
ORDER BY Total_Sales DESC;

CREATE VIEW sales_summary AS
SELECT
    category,
    region,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM superstore_sales
GROUP BY category, region;

SELECT *
FROM sales_summary;

SELECT
    product_name,
    SUM(sales) AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM superstore_sales
GROUP BY product_name;

SELECT
    category,
    product_name,
    total_sales
FROM (
    SELECT
        category,
        product_name,
        SUM(sales) AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY SUM(sales) DESC
        ) AS rn
    FROM superstore_sales
    GROUP BY category, product_name
) ranked
WHERE rn = 1;

SELECT
    YEAR(order_date) AS yr,
    MONTH(order_date) AS mn,
    SUM(sales) AS monthly_sales,
    SUM(SUM(sales)) OVER (
        ORDER BY YEAR(order_date), MONTH(order_date)
    ) AS running_total
FROM superstore_sales
GROUP BY YEAR(order_date), MONTH(order_date);

SELECT
    customer,
    SUM(sales) AS total_sales
FROM superstore_sales
GROUP BY customer
HAVING SUM(sales) >
(
    SELECT AVG(customer_sales)
    FROM
    (
        SELECT SUM(sales) AS customer_sales
        FROM superstore_sales
        GROUP BY customer
    ) t
)
ORDER BY total_sales DESC;