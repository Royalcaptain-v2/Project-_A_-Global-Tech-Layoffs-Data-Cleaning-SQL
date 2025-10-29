# Project-_A_-Global-Tech-Layoffs-Data-Cleaning-SQL
The Project involves cleaning the Dataset of the employees layed-off from Companies in 2022-2023

## Data Cleaning Project — Global Tech Layoffs (2022–2023)

This project focuses on cleaning and standardizing the **Global Tech Layoffs Dataset (2022–2023)** using **MySQL**.

###  Objectives
- Remove duplicates  
- Standardize company, country, and industry names  
- Handle NULLs and blanks  
- Convert date columns into SQL `DATE` format  
- Prepare the dataset for EDA  

### Tools
- MySQL 8.0
- SQL Window Functions (`ROW_NUMBER()`)
- CTEs and Self-Joins

### Workflow Overview
1. Import raw CSV → Create staging tables  
2. Identify and remove duplicates  
3. Clean text entries using TRIM and LIKE  
4. Handle NULLs and missing values via self-join updates  
5. Format dates into proper `DATE` type  
6. Drop helper columns  

### Outcome
A clean and analysis-ready dataset (`layoffs_staging2`) ready for EDA and visualization.

---

### Files Included
- `global_tech_layoffs_cleaning.sql` → Full SQL cleaning script  
- `raw_dataset.csv` → Original unaltered dataset  
- `cleaned_dataset.csv` → Final cleaned version  
- `screenshots/` → Code and result snapshots
