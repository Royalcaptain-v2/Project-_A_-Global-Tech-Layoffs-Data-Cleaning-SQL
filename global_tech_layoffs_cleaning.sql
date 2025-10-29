-- DATA CLEANING PROJECT — GLOBAL TECH LAYOFFS (2022–2023)
-- Author: Bhavishya Pancholi
-- Database: MySQL 8.0
-- Description: Cleaning and preparing the Global Tech Layoffs dataset
-- --------------------------------------------------------

-- Data cleaning - The .csv file imported is in raw form which means no data type of any column is changed including date

SELECT * FROM layoffs;

# STEPS FOR DATA CLEANING 
-- 1. Remove Duplicates if Any.
-- 2. Standardize the Data - Check for errors in data like Spellings
-- 3. NULL values or Blank values - When to fill and when not to !
-- 4. Remove any columns or Rows
		# when to remove - For very large data set and no ETL process , remove the whole column
        # when not remove -  In real workplace where processess automatically imports new data from different data sources 
						-- Don't remove column of RAW datasets
		
CREATE TABLE layoffs_staging #to not disturb the real raw data we created a new copy of that data's columns
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- WITH duplicate_cte AS 
-- (
-- SELECT * ,
-- ROW_NUMBER() OVER(PARTITION BY company , industry , total_laid_off , percentage_laid_off , `date`) AS row_num
-- # date included in ticks because it is a keyword
-- FROM layoffs_staging
-- )
-- SELECT * 
-- FROM duplicate_cte
-- WHERE row_num >1 #if row_num >1 then it tells that there are duplicates which row number shows using partition by
-- ;

-- #lets select Oda company randomly to check whether data is really the same 
-- SELECT * FROM layoffs_staging
-- where company = 'Oda';

#entries are not really same -
#Oda	Oslo	Food	70	0.18	11/1/2022	Unknown	Sweden	377
#Oda	Oslo	Food	70	0.18	11/1/2022	Unknown	Norway	477
#Oda	Oslo	Food	70	0.06	11/1/2022	Unknown	Norway	479
#change for all parameters of duplicate_example

WITH duplicate_cte AS 
(
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company ,location, industry , 
total_laid_off , percentage_laid_off , `date`, stage , country , funds_raised_millions) AS row_num
# date included in ticks because it is a keyword
FROM layoffs_staging 
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1 
;

# lets check for casper for duplicates
SELECT *
FROM layoffs_staging 
WHERE company = 'Casper';
#i wrote row _num to understand how duplicates are numbered so as to make new table and then remove that duplicate 
-- Casper	New York City	Retail			9/14/2021	Post-IPO	United States	339   -- row_num =1
-- Casper	New York City	Retail	78	0.21	4/21/2020	Post-IPO	United States	339  --row_num=1
-- Casper	New York City	Retail			9/14/2021	Post-IPO	United States	339  --row_num =2 this is how they are numbered 
# First and last values are same  - Remove only one - which means one with row_num =2 must be removed 

#next right click layoffs_staging -> copy to clipboard -> create statement

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL ,
  `row_num` INT 								#added later
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company ,location, industry , 
total_laid_off , percentage_laid_off , `date`, stage , country , funds_raised_millions) AS row_num
FROM layoffs_staging ;

SELECT * FROM layoffs_staging2
WHERE row_num >1;

DELETE FROM layoffs_staging2
WHERE row_num>1;

-- Standardizing Data - Finding issues and fixing them 

SELECT company , TRIM(company) 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

#next check for industry 
SELECT DISTINCT industry FROM layoffs_staging2 
ORDER BY 1;
#These 3 values are same but written differently which will cause problems in EDA later
-- Crypto
-- Crypto Currency
-- CryptoCurrency
SELECT DISTINCT industry FROM layoffs_staging2 
ORDER BY 1;

SELECT * FROM layoffs_staging2 
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry FROM layoffs_staging2 
ORDER BY 1;

SELECT * FROM layoffs_staging2
ORDER BY 1;

#next check location - All looks Fine 
SELECT DISTINCT location from layoffs_staging2 ;
#next check country 
SELECT DISTINCT country FROM layoffs_staging2
ORDER BY 1;

#one US has a fullstop 
-- United States
-- United States.

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT DISTINCT country 
FROM layoffs_staging2 ORDER BY 1;  

#Another WorkAround 
-- SELECT DISTINCT country , TRIM(TRAILING '.' FROM country)
-- FROM layoffs_staging2 ORDER BY 1;

-- UPDATE layoffs_staging2
-- SET country =TRIM(TRAILING '.' FROM country)
-- WHERE country LIKE 'United States%';
 
 #Now to perform EDA or Time Series the date should have the format of a date not the text
 
 SELECT `date`,
 STR_TO_DATE(`date` , '%m/%d/%Y')
 FROM layoffs_staging2;
 
 UPDATE layoffs_staging2
 SET `date` =  STR_TO_DATE(`date` , '%m/%d/%Y');
 
 #after checking date column through scheme on left we see its format changed but type hasn't changed
 ALTER TABLE layoffs_staging2
 MODIFY COLUMN `date` DATE;
 
 SELECT * FROM layoffs_staging2;
 
		-- REMOVE NULLS and BLANKS
 
 SELECT * FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL; #So many values are NULL on both columns , these are deemed useless
 
 #But first lets see industry 
 SELECT * 
 FROM layoffs_staging2
 WHERE industry IS NULL
 OR industry = '';
 #Airbnb	SF Bay Area	 blank  30	 Null - one of the entries is like this where industry is blank 
 -- we can fill it if there are other layoffs with the industry name 
 SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb'; 
-- we find one entry where industry is told -Airbnb	SF Bay Area	Travel	1900	0.25 -  travel industry

SELECT st1.company ,st1.industry , st2.industry 
FROM layoffs_staging2 st1 
JOIN layoffs_staging2 st2
	ON st1.company = st2.company
WHERE (st1.industry IS NULL OR st1.industry = '' )
AND (st2.industry IS NOT NULL AND st2.industry != '');
 
 UPDATE layoffs_staging2 st1
 JOIN layoffs_staging2 st2
	ON st1.company = st2.company
SET st1.industry = st2.industry 
WHERE (st1.industry IS NULL OR st1.industry = '' )
AND (st2.industry IS NOT NULL AND st2.industry != '');
#instead of making everything to NULL add one more statement to selection column and update column i made a workaround in the st2 statements in WHERE part 
#of both select and update statement 
#this extra st2.industry IS NOT NULL AND st2.industry != '' line will ensure that there are no blanks and also no null in the other joined table st2.
#else it will join blanks too

-- now check if there are any null or blank in industry 

SELECT* FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';
 # one entry is still null Bally's Interactive	Providence			0.15	2023-01-18	Post-IPO	United States	946	1
 #check how many entries of Belly are there
 SELECT * FROM layoffs_staging2 
 WHERE company LIKE 'Bally%'; -- only one where industry is null and there are no one else to populate it so leave it

-- total_laid_off cannot be populated with values because laid off percentage is given but total employees of organization not given 
-- funds raised also cannot be populated because there is no lead so delete rows with these values beacuse they are useless 
-- Similarly stage and funds column cannot be filled because they are factual

SELECT * FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2;
#now delete row_num column which is useless now 
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;
#Now the Data is successfully Cleaned 
-- Completed project one .
-- Next is Exploratory Data Analysis
