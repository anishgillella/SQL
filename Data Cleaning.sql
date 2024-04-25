-- Data Cleaning
 
use world_layoffs;
select * from layoffs;

-- Step 2: Standardise the data

-- Step 3: Looking at null values and blank values

-- Step 4: Remove any columns or rows which aren't necessary

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

select * from layoffs_staging;

-- Step 1 : Remove duplicates
select *, 
row_number() over(
partition by company, industry, total_laid_off,percentage_laid_off, 'date') as row_num
from layoffs_staging;

-- Creating CTE for the above function
with duplicate_cte as (
select *, 
row_number() over(
partition by company, industry, total_laid_off,percentage_laid_off, 'date') as row_num
from layoffs_staging
)

SELECT * from duplicate_cte where row_num > 1;

-- Now let's check for a single company
SELECT * from layoffs_staging where company = 'Oda';

-- let's do the partition by every single column as Oda doesn't have any duplicates
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, 
            total_laid_off, percentage_laid_off, `date`, stage,
            country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)

SELECT * FROM duplicate_cte
WHERE row_num > 1; -- Adjust accordingly to manage duplicates



SELECT * 
from layoffs_staging
where company = 'Casper';

-- Deleting the duplicates
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, 
            total_laid_off, percentage_laid_off, `date`, stage,
            country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1; -- Adjust accordingly to manage duplicates

-- Creating a new table to delete it's rows
CREATE TABLE `layoffs_staging2` (
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


SELECT * 
from layoffs_staging2;

INSERT INTO layoffs_staging2
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, 
            total_laid_off, percentage_laid_off, `date`, stage,
            country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

select * 
from layoffs_staging2 
where row_num>1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

select * 
from layoffs_staging2;


-- Step 2: Standardizing the data
SELECT company, trim(company)
from layoffs_staging2;

UPDATE layoffs_staging2
SET company = trim(company);

select distinct(industry)
from layoffs_staging2
order by 1;

-- Cryptocurrency is one industry whose text in the rows needs to be standardized
select *
from layoffs_staging2
where industry like "Crypto%";


update layoffs_staging2
set industry = 'Crypto'
where industry like "Crypto%";

select *
from layoffs_staging2;

select distinct(location)
from layoffs_staging2
order by 1;

select distinct(country)
from layoffs_staging2
order by 1;

select distinct(country),trim(trailing '.' from country)
from layoffs_staging2
where country like 'United States%'
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like "United States%";

select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

select `date`,
str_to_date(`date`,'%m/%d/%y')
from layoffs_staging2;

UPDATE layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER table layoffs_staging2
modify column `date` DATE;

SELECT * FROM layoffs_staging2;

-- Step 3: Null and Blank values
SELECT * FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


SELECT * FROM layoffs_staging2
where industry is null
or industry = '';

SELECT * 
FROM layoffs_staging2
where company like 'Bally%';

update layoffs_staging2
set industry = 'Travel'
where company = 'Airbnb';

select t1.industry,t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
	and t1.location = t2.location
    where (t1.industry is null) or t1.industry = ''
    and t2.industry is not null;

 update layoffs_staging2 t1
 join layoffs_staging2 t2
 on t1.company = t2.company
 set t1.industry = t2.industry
 where t1.industry is null
    and t2.industry is not null;
    
-- Update it to set the blanks to null
update layoffs_staging2
set industry  = NULL
where industry = "";

select *
from layoffs_staging2;

-- Step 4
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- So we can get rid of these rows as this doesn;t contribute to any insights
DELETE
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * 
from layoffs staging2;

alter table layoffs_staging2
drop column row_num;














