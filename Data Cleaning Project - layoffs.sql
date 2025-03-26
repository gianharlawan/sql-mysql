-- Data Cleaning Learning Project
-- I follow step by step from AlexTheAnalyst on Youtube https://youtu.be/4UltKCnnnTA?si=P4NLYY8U7E5g4Eh-
-- Here's the datasets https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv

SELECT *
FROM world_layoff.layoffs;

SELECT COUNT(*)
FROM world_layoff.layoffs;

-- Data cleaning steps
	-- 1. Remove any duplicates data
	-- 2. Standardize the data format
	-- 3. Look at null or blank values
    -- 4. Remove columns and rows that are not necessary


-- Create duplicate table as our working table for data cleaning, and keep raw data as backup in case something happens
CREATE TABLE layoffs_duplicate
LIKE layoffs;

INSERT layoffs_duplicate
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_duplicate;

-- 1. Removing Duplicates

-- first we need to assign a row number to each row as an identifier for duplicate detection
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
			as row_num
FROM layoffs_duplicate;
        
-- then we need see if any row number greater than 1 
WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
			as row_num
	FROM layoffs_duplicate
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- delete the duplicates
-- We need to create another duplicate table with an added row_num column. Alternatively, we can add row_num beforehand to avoid making another duplicate.
CREATE TABLE `layoffs_duplicate2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_duplicate2
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
			as row_num
	FROM layoffs_duplicate;

SELECT *
FROM layoffs_duplicate2
WHERE row_num > 1
;

-- All clear and delete the duplicates
DELETE
FROM layoffs_duplicate2
WHERE row_num > 1
;

-- 2. Standardize the data

SELECT *
FROM layoffs_duplicate2;

-- Trim (remove white space)
SELECT company, TRIM(company)
FROM layoffs_duplicate2
;

UPDATE layoffs_duplicate2
SET company = TRIM(company)
;

-- Double entity with same meaning like typo or bad spelling
SELECT DISTINCT industry
FROM layoffs_duplicate2
ORDER BY 1;

UPDATE layoffs_duplicate2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT country
FROM layoffs_duplicate2
ORDER BY 1;

UPDATE layoffs_duplicate2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Date Format
SELECT `date`,
	STR_TO_DATE (`date`, '%m/%d/%Y')
FROM layoffs_duplicate2;

UPDATE layoffs_duplicate2
SET `date` = STR_TO_DATE (`date`, '%m/%d/%Y');

ALTER TABLE layoffs_duplicate2
MODIFY COLUMN `date` DATE;


-- 3. Look at null or blank values

SELECT *
FROM layoffs_duplicate2
WHERE industry IS NULL
	OR industry = '';

-- so there's a few null and blank values. let's take a sample
SELECT *
FROM layoffs_duplicate2
WHERE company = 'Airbnb';

-- it turns out Airbnb is a travel industry. however, there's column that contains null or blank values
-- so let's update it. also we need to make some auto-update so we don't have to check one by one in case we have a lot of data

-- first we need to change blank to null to make it easy
UPDATE layoffs_duplicate2
SET industry = NULL
WHERE industry = '';

-- now we update the null values in the industry column when the company name is the same
SELECT *
FROM layoffs_duplicate2 t1
JOIN layoffs_duplicate2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
	AND t2.industry IS NOT NULL
;

UPDATE layoffs_duplicate2 t1
JOIN layoffs_duplicate2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
	AND t2.industry IS NOT NULL
;
-- we also had a few null values in total_laid_off column and percentage_laid_off column
-- however we can't update it because we lack of information.


-- 4. Remove columns and rows that are not necessary

-- let's delete the data where total_laid_off and percentage_laid_off is null values
-- cause it's lack information and we can't really use
-- in real professional world, we actually need to inform the spv or lead before we get rid of it
-- or it probably null is 0, so we need just to make sure before we delete the data
-- but cause it learning project so let just stick with the tutorial

SELECT *
FROM layoffs_duplicate2
WHERE total_laid_off is NULL
	AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_duplicate2
WHERE total_laid_off is NULL
	AND percentage_laid_off IS NULL;
    
ALTER TABLE layoffs_duplicate2
DROP COLUMN row_num;    

SELECT *
FROM layoffs_duplicate2;

-- DONE. we'll use this cleaned data on Exploratory Data Analysis learning project









