-- Data Preparation

CREATE TABLE public.layoffs_2(
    company              TEXT,
    location             TEXT,
    industry             TEXT,
    total_laid_off       INTEGER,
    percentage_laid_off  NUMERIC(10,2),
    layoff_date          TEXT,
    stage                TEXT,
    country              TEXT,
    funds_raised         NUMERIC(12,2)
);

SELECT * FROM layoffs_2;

-- Import Data menggunakan SQL

-- prompt buat di SQL

-- \copy public.layoffs_2
-- FROM 'C:\Users\yuliatun\Documents\DATA ANALIS\SQL\layoffs.csv'
-- WITH (
   -- FORMAT csv,
   -- DELIMITER ',',
   -- HEADER,
   -- QUOTE '"',
   -- NULL 'NULL'
-- );

-- DATA CLEANING

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values 0r blank Values
-- 4. Remove any Columns


CREATE TABLE layoffs_copy 
(LIKE layoffs_2 INCLUDING ALL);

INSERT INTO layoffs_copy
SELECT * FROM layoffs_2;

select * from layoffs_copy;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_copy;

-- USE CTE

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised) AS row_num
FROM layoffs_copy
)
SELECT * FROM duplicate_cte 
WHERE row_num > 1;

select * from layoffs_copy
WHERE company = 'Casper';


-- DELETE DUPLICATE
--is not working so make new table
 -- WITH duplicate_cte AS 
--(
-- SELECT *,
-- ROW_NUMBER() OVER(
-- PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised) AS row_num
-- FROM layoffs_copy
-- )
-- DELETE  FROM duplicate_cte 
-- WHERE row_num > 1;


-------------------- new table ---------------------

-- Table: public.layoffs_copy

-- DROP TABLE IF EXISTS public.layoffs_copy;

CREATE TABLE IF NOT EXISTS public.layoffs_staging3
(
    company text COLLATE pg_catalog."default",
    location text COLLATE pg_catalog."default",
    industry text COLLATE pg_catalog."default",
    total_laid_off integer,
    percentage_laid_off numeric(10,2),
    layoff_date text COLLATE pg_catalog."default",
    stage text COLLATE pg_catalog."default",
    country text COLLATE pg_catalog."default",
    funds_raised int DEFAULT NULL,
	row_num  INT
	
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.layoffs_staging3
    OWNER to postgres;

SELECT * FROM layoffs_staging3;

INSERT INTO layoffs_staging3
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised) AS row_num
FROM layoffs_copy;

SELECT * FROM layoffs_staging3
WHERE row_num > 1;

DELETE FROM layoffs_staging3
WHERE row_num > 1;

SELECT * FROM layoffs_staging3
WHERE row_num > 1;

SELECT * FROM layoffs_staging3;

-- STANDARDIZE DATA

SELECT company, TRIM(company)
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET company =  TRIM(company);

SELECT *
FROM layoffs_staging3
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry 
FROM layoffs_staging3;

-- TRIM PERIOD AT THE END
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging3
Order BY 1;

UPDATE layoffs_staging3
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- CHANGE TYPEDATA OF DATE

SELECT layoff_date,
TO_DATE(layoff_date, 'MM/DD/YY')
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET layoff_date = TO_DATE(layoff_date, 'MM/DD/YY');

SELECT layoff_date
FROM layoffs_staging3;


ALTER TABLE layoffs_staging3
ALTER COLUMN layoff_date TYPE DATE USING layoff_date::DATE;



-- REMOVE NULL AND BLANK VALUES

SELECT * 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging3
WHERE industry IS NULL
OR industry = '';


SELECT *
FROM layoffs_staging3
WHERE company LIKE 'Bally%';

-- join

SELECT t1.industry, t2.industry
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company 

WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging3 t1
SET industry = t2.industry
FROM layoffs_staging3 t2
WHERE t1.company = t2.company
AND t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- changing blank to null

UPDATE layoffs_staging3
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- delete data if u confidence about data
DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging3;

ALTER TABLE layoffs_staging3
DROP COLUMN row_num;






