-- Data Cleaning Learning Project
-- I follow step by step from AlexTheAnalyst on Youtube https://youtu.be/QYd-RtK58VQ?si=ynoPGvC_i_msMHK3
-- Here's the datasets https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv

SELECT * 
FROM world_layoff.layoffs_duplicate2;

-- let's see which company had large percentage of laid off
SELECT MAX(total_laid_off)
FROM world_layoff.layoffs_duplicate2
;

SELECT *
FROM world_layoff.layoffs_duplicate2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
;

SELECT company, SUM(total_laid_off)
FROM layoffs_duplicate2
GROUP BY company
ORDER BY 2 DESC;

-- let's see the time period
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_duplicate2
;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_duplicate2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

-- let's see time period by month
SELECT SUBSTRING(`date`,6,2) AS `Month`, SUM(total_laid_off)
FROM layoffs_duplicate2
GROUP BY 1
ORDER BY 1
;

SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM layoffs_duplicate2
GROUP BY 1
ORDER BY 1
;

-- also what's industry that had most laid off
SELECT industry, SUM(total_laid_off)
FROM layoffs_duplicate2
GROUP BY industry
ORDER BY 2 DESC;


-- let's see the rolling total of laid off (based on month)
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM layoffs_duplicate2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY 1
ORDER BY 1
;

WITH Rolling_Total AS
	(
    SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
	FROM layoffs_duplicate2
	WHERE SUBSTRING(`date`,1,7) IS NOT NULL
	GROUP BY 1
	ORDER BY 1
	)

SELECT 
	`Month`, 
    total_off,
	SUM(total_off) OVER (ORDER BY `Month`) AS Rolling_Total
FROM Rolling_Total;

-- let's breakdown the total laid off for each company every year
SELECT 
	company, 
	YEAR(`date`),
	SUM(total_laid_off)
FROM layoffs_duplicate2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

-- let's rank them which company had most laid off in each year
WITH company_rank (company, years, total_laid_off) AS
(
	SELECT 
		company, 
		YEAR(`date`),
		SUM(total_laid_off)
	FROM layoffs_duplicate2
	GROUP BY company, YEAR(`date`)
),
company_year_rank AS
(
	SELECT 
		*,
		DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM company_rank
	WHERE years IS NOT NULL
)

SELECT *
FROM company_year_rank
WHERE ranking <= 5
;



