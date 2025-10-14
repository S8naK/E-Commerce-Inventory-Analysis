DROP TABLE IF EXISTS zepto;

-- Loaded Data using Table Data Import Wizard

-- Creating a Primary Key sku_id

ALTER TABLE zepto
ADD COLUMN sku_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE zepto
CHANGE COLUMN discountedSellingPrice discountedSellingPrice DECIMAL(8,2) NULL DEFAULT NULL;
SELECT name, discountedSellingPrice FROM zepto ORDER BY discountedSellingPrice DESC LIMIT 10;

/*
===============================================================================
Database Exploration
===============================================================================
*/

-- Sample Data
SELECT * FROM zepto LIMIT 10;

-- Count Of Rows
SELECT COUNT(*) FROM zepto;

-- Retrieve all columns table zepto
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'zepto';

-- null values
SELECT * FROM zepto
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
FROM zepto
ORDER BY Category;

-- Products in stock vs out of stock
SELECT COUNT(*) FROM zepto
WHERE outOfStock = 'TRUE';