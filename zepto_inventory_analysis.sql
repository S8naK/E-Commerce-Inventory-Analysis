DROP TABLE IF EXISTS zepto;

-- Loaded Data using Table Data Import Wizard

/*
===============================================================================
Data Cleaning
===============================================================================
*/
-- Cleaned the raw CSV using Python (Pandas)
-- Steps performed in Python before loading into MySQL:
--   1. Removed products where mrp = 0 or discountedSellingPrice = 0
--   2. Converted prices from paise to rupees
--   3. Converted outOfStock column from 'TRUE'/'FALSE' to 1/0
-- Loaded cleaned data into MySQL table `zepto_clean` using SQLAlchemy engine
-- Connection example: mysql+mysqlconnector://root:root@localhost/zepto_sql_project


-- Creating a Primary Key sku_id

ALTER TABLE zepto_clean
ADD COLUMN sku_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE zepto_clean
CHANGE COLUMN discountedSellingPrice discountedSellingPrice DECIMAL(8,2) NULL DEFAULT NULL;
SELECT name, discountedSellingPrice FROM zepto ORDER BY discountedSellingPrice DESC LIMIT 10;

/*
===============================================================================
Database Exploration
===============================================================================
*/

-- Sample Data
SELECT * FROM zepto_clean LIMIT 10;

-- Count Of Rows
SELECT COUNT(*) FROM zepto_clean;

-- Retrieve all columns table zepto_clean
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'zepto_clean';

-- null values
SELECT * FROM zepto_clean
WHERE name IS NULL
	OR Category IS NULL
	OR mrp IS NULL
	OR discountPercent IS NULL
	OR discountedSellingPrice IS NULL
	OR weightInGms IS NULL
	OR availableQuantity IS NULL
	OR outOfStock IS NULL
	OR quantity IS NULL;
    
-- Different Product Categories
SELECT DISTINCT Category 
FROM zepto_clean
ORDER BY Category;

-- Products per category
SELECT Category, COUNT(*) AS total_products
FROM zepto_clean
GROUP BY Category
ORDER BY total_products DESC;


-- Products in stock vs out of stock
SELECT outOfStock, COUNT(*)
FROM zepto_clean
GROUP BY outOfStock;

-- Product names present multiple times
SELECT name, COUNT(*) AS "Number of times"
FROM zepto_clean
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- Summary statistics for numeric columns
SELECT 
    MIN(mrp) AS min_mrp,
    MAX(mrp) AS max_mrp,
    AVG(mrp) AS avg_mrp,
    MIN(discountPercent) AS min_discount,
    MAX(discountPercent) AS max_discount,
    AVG(discountPercent) AS avg_discount,
    MIN(weightInGms) AS min_weight,
    MAX(weightInGms) AS max_weight,
    AVG(weightInGms) AS avg_weight
FROM zepto_clean;

-- Discount distribution
SELECT discountPercent, COUNT(*) AS count_products
FROM zepto_clean
GROUP BY discountPercent
ORDER BY discountPercent DESC;

-- MRP vs discountedSellingPrice comparison
SELECT name, mrp, discountedSellingPrice, (mrp - discountedSellingPrice) AS discount_amount
FROM zepto_clean
ORDER BY discount_amount DESC;

-- Weight Distribution
SELECT weightInGms, COUNT(*) AS count_products
FROM zepto_clean
GROUP BY weightInGms
ORDER BY weightInGms DESC;


/*
===============================================================================
Data Analysis
===============================================================================
*/

-- Q1. Find the top 10 best-value products based on the discount percentage.
-- Q2. What are the Products with High MRP but Out of Stock
-- Q3. Calculate Estimated Revenue for each category
-- Q4. Find the top 5 categories generating the most estimated revenue.
-- Q5. What is the Total Inventory Weight Per Category
-- Q6. Find the Top 3 Most Expensive Products per Category
-- Q7. Find the Average Discount per Category and Show Beside Each Product
-- Q8. Show each product's percentage contribution to category revenue
-- Q9. Find all products where MRP is greater than ₹500 and discount is less than 10%.
-- Q10. Identify the top 5 categories offering the highest average discount percentage.
-- Q11. Find the price per gram for products above 100g and sort by best value.
-- Q12.Group the products into categories like Low, Medium, Bulk.

-- Q13. Which categories have the highest number of unique products?
-- Q14. Find categories with the highest average MRP per product.
-- Q15. Identify products with the highest markup (difference between MRP and discountedSellingPrice).
-- Q16. Find the total number of out-of-stock products per category.
-- Q17. Identify products with high discount but low stock (potential sell-out risk).
-- Q18. Find products with zero discount but still out of stock (high demand items)
-- Q19. Find the correlation between discount percentage and stock availability.


-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto_clean
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2.What are the Products with High MRP but Out of Stock
SELECT DISTINCT name, mrp
FROM zepto_clean
WHERE outOfStock = 1 and mrp > 250
ORDER BY mrp DESC;

-- Q3.Calculate Estimated Revenue for each category
SELECT Category, SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto_clean
GROUP BY Category
ORDER BY total_revenue DESC;

-- Q4. Find the top 5 categories generating the most estimated revenue.
SELECT Category, SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto_clean
GROUP BY Category
ORDER BY total_revenue DESC
LIMIT 5;

-- Q5.What is the Total Inventory Weight Per Category 
SELECT Category, SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto_clean
GROUP BY Category
ORDER BY total_weight DESC;

-- Q6. Find the Top 3 Most Expensive Products per Category
SELECT *
FROM (
    SELECT 
        Category, name, mrp, ROW_NUMBER() OVER (PARTITION BY Category ORDER BY mrp DESC) AS rank_in_category
    FROM zepto_clean
) ranked
WHERE rank_in_category <= 3
ORDER BY Category, mrp DESC, name;

-- Q7. Find the Average Discount per Category and Show Beside Each Product
SELECT category, name, discountPercent, ROUND(AVG(discountPercent) OVER (PARTITION BY category),2) AS avg_discount_category
FROM zepto_clean
ORDER BY category, discountPercent DESC;

-- Q8. Show each product's percentage contribution to category revenue
SELECT 
    Category, name, discountedSellingPrice * quantity AS Product_Revenue,
    SUM(discountedSellingPrice * quantity) OVER (PARTITION BY Category) AS Category_Total_Revenue,
    ROUND(
        (discountedSellingPrice * quantity) * 100.0 /
        SUM(discountedSellingPrice * quantity) OVER (PARTITION BY Category),
        2
    ) AS Percentage_Contribution
FROM zepto_clean
ORDER BY Category, Percentage_Contribution DESC;

-- Q9. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto_clean
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q10. Identify the top 5 categories offering the highest average discount percentage.
SELECT Category, ROUND(AVG(discountPercent),2) AS avg_discount_percent
FROM zepto_clean
GROUP BY Category
ORDER BY avg_discount_percent DESC
LIMIT 5;

-- Q11. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice, ROUND(discountedSellingPrice/weightInGms, 2) AS price_per_gm
FROM zepto_clean
WHERE weightInGms >= 100
ORDER BY price_per_gm;

-- Q12. Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
	CASE 
		WHEN weightInGms <= 1000 THEN 'Low'
        WHEN weightInGms <= 5000 THEN 'Medium'
        ELSE 'Bulk'
        END AS weight_category
FROM zepto_clean;

-- Q13. Which categories have the highest number of unique products?
SELECT Category, COUNT(DISTINCT name) AS unique_products
FROM zepto_clean
GROUP BY Category
ORDER BY unique_products DESC;

-- Q14. Find categories with the highest average MRP per product.
SELECT Category, ROUND(AVG(mrp), 2) AS avg_mrp
FROM zepto_clean
GROUP BY Category
ORDER BY avg_mrp DESC;

-- Q15. Identify products with the highest markup (difference between MRP and discountedSellingPrice).
SELECT name, Category, mrp, discountedSellingPrice, (mrp - discountedSellingPrice) AS markup
FROM zepto_clean
ORDER BY markup DESC
LIMIT 10;

-- Q16. Find the total number of out-of-stock products per category.
SELECT Category, COUNT(*) AS out_of_stock_count
FROM zepto_clean
WHERE outOfStock = '1'
GROUP BY Category
ORDER BY out_of_stock_count DESC;

-- Q17. Identify products with high discount but low stock (potential sell-out risk).
SELECT name, Category, discountPercent, availableQuantity
FROM zepto_clean
WHERE discountPercent > 40 AND availableQuantity < 7
ORDER BY discountPercent DESC;

-- Q18. Find products with zero discount but still out of stock (high demand items)
SELECT name, Category, mrp, discountedSellingPrice
FROM zepto_clean
WHERE discountPercent = 0 AND outOfStock = 0
ORDER BY discountedSellingPrice DESC;

-- Q19. Find the correlation between discount percentage and stock availability.
SELECT 
    CASE 
        WHEN discountPercent < 10 THEN 'Low Discount'
        WHEN discountPercent BETWEEN 10 AND 30 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_range,
    AVG(CASE WHEN outOfStock = 0 THEN 1 ELSE 0 END) * 100 AS percent_out_of_stock
FROM zepto_clean
GROUP BY discount_range
ORDER BY percent_out_of_stock DESC;