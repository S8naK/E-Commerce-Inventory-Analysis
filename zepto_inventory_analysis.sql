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










