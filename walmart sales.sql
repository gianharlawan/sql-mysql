/* Hello, 
this is walmart sales project using MySQL (Cleaning & EDA) and Tableau (Visualization).
the dataset is about walmart sales with influence factors like holiday, purhase index, unemployee rate, etc.
here's the dataset link https://www.kaggle.com/datasets/mikhail1681/walmart-sales/ 
*/

-- First, let's start some cleaning process of the dataset
SELECT * 
FROM walmart_project.walmart_sales
;

DESCRIBE walmart_sales;

-- so first, let's check NULL values
SELECT * 
FROM walmart_sales
WHERE Store IS NULL 
   OR `Date` IS NULL
   OR Weekly_Sales IS NULL
   OR Holiday_Flag IS NULL
   OR Temperature IS NULL
   OR Fuel_Price IS NULL
   OR CPI IS NULL
   OR Unemployment IS NULL;
   
UPDATE walmart_sales
SET Weekly_Sales = 0
WHERE Weekly_Sales = '';

   
-- 0 row(s) returned, there's no NULL values
-- then, the next we want to do is change Date format

SELECT `Date`,
	STR_TO_DATE (`Date`, '%d-%m-%Y')
FROM walmart_sales;

UPDATE walmart_sales 
SET `Date` = STR_TO_DATE (`Date`, '%d-%m-%Y');

ALTER TABLE walmart_sales
MODIFY `Date` DATE;

-- 6435 row(s) affected Records: 6435  Duplicates: 0  Warnings: 0

-- Next, let's check for duplicate row
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY Store, `Date`, Weekly_Sales, Holiday_Flag, Temperature, Fuel_Price, CPI, Unemployment)
			as row_num
FROM walmart_sales;

WITH dup_check AS (
	SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY Store, `Date`, Weekly_Sales, Holiday_Flag, Temperature, Fuel_Price, CPI, Unemployment)
			as row_num
	FROM walmart_sales
)

SELECT *
FROM dup_check
WHERE row_num > 1;

-- 0 row(s) returned
-- So, looks like the dataset is pretty clean hah
-- Also if there's a duplicate, in MySQL we cannot delete it directly from cte, so we need some id to define every row
-- Let's do for demonstration

ALTER TABLE walmart_sales 
	ADD COLUMN id 
	INT AUTO_INCREMENT PRIMARY KEY;
-- okay it's works so just drop the column id
ALTER TABLE walmart_sales DROP COLUMN id;


-- convert Temperature to Celcius, CAREFUL not to double execute
UPDATE walmart_sales
SET Temperature = (Temperature - 32) * 5/9;

-- if that happens, here's the counter
UPDATE walmart_sales
SET Temperature = (Temperature * 9 / 5) + 32;


-- last check
SELECT Store, Date, Weekly_Sales, COUNT(*) 
FROM walmart_sales
GROUP BY Store, Date, Weekly_Sales, Holiday_Flag, Temperature, Fuel_Price, CPI, Unemployment
HAVING COUNT(*) > 1;

SELECT * FROM walmart_sales 
WHERE Weekly_Sales < 0 OR Temperature < -50 OR Temperature > 50;

-- 0 row(s) returned
SELECT * 
FROM walmart_project.walmart_sales
;

-- Okay, I think it's all set.
-- before we make the data visualization, let's do some exploratory.

SELECT COUNT(*) AS total_rows 
FROM walmart_sales;

SELECT 
    MIN(Weekly_Sales) AS min_sales, 
    MAX(Weekly_Sales) AS max_sales, 
    AVG(Weekly_Sales) AS avg_sales, 
    STDDEV(Weekly_Sales) AS std_sales,
    MIN(Temperature) AS min_temp, 
    MAX(Temperature) AS max_temp, 
    AVG(Temperature) AS avg_temp,
    MIN(Fuel_Price) AS min_fuel, 
    MAX(Fuel_Price) AS max_fuel, 
    AVG(Fuel_Price) AS avg_fuel
FROM walmart_sales;

-- let's see the variation of weekly sales based on store and sales month.
SELECT Store, MONTH(Date) AS sales_month, Weekly_Sales
FROM walmart_sales
WHERE Weekly_Sales < (SELECT AVG(Weekly_Sales) - 2 * STDDEV(Weekly_Sales) FROM walmart_sales)
   OR Weekly_Sales > (SELECT AVG(Weekly_Sales) + 2 * STDDEV(Weekly_Sales) FROM walmart_sales)
ORDER BY sales_month, Weekly_Sales DESC;

-- compare week that had holiday and non-holiday by avg sales
SELECT 
    Holiday_Flag,
    COUNT(*) AS weeks_count,
    AVG(Weekly_Sales) AS avg_sales
FROM walmart_sales
GROUP BY Holiday_Flag;

-- let's see top ten good and bad performance by store
SELECT Store, SUM(Weekly_Sales) AS total_sales
FROM walmart_sales
GROUP BY Store
ORDER BY total_sales DESC
LIMIT 10;

SELECT Store, SUM(Weekly_Sales) AS total_sales
FROM walmart_sales
GROUP BY Store
ORDER BY total_sales ASC
LIMIT 10;

-- let's see the impact of external factor (temperature, fuel price, and unemployee rate) with avg sales
SELECT ROUND(Temperature, 0) AS temperature, AVG(Weekly_Sales) AS avg_sales
FROM walmart_sales
GROUP BY 1
ORDER BY 1;

SELECT ROUND(Fuel_Price, 2) AS fuel_price, AVG(Weekly_Sales) AS avg_sales
FROM walmart_sales
GROUP BY 1
ORDER BY 1;

SELECT ROUND(Unemployment, 1) AS unemployment_rate, AVG(Weekly_Sales) AS avg_sales
FROM walmart_sales
GROUP BY 1
ORDER BY 1;

-- Okay, i think that's all for the SQL project, now we'll create the visualization and analysis of the data.






