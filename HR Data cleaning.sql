-- select schema to use
USE human_resources;

-- check data type 
DESCRIBE hr;

-- Check for missing values
select ï»¿id from hr where ï»¿id = '' or ï»¿id is null;
select first_name from hr where first_name = '' or first_name is null;
select last_name from hr where last_name = '' or last_name is null;
select birthdate from hr where birthdate = '' or birthdate is null;
select gender from hr where gender = '' or gender is null;
select race from hr where race = '' or race is null;
select department from hr where department = '' or department is null;
select jobtitle from hr where jobtitle = '' or jobtitle is null;
select location from hr where location = ''or location is null;
select hire_date from hr where hire_date is null or hire_date is null;
select termdate from hr where termdate= '' or termdate is null; #empty string values present termdate;
select location_city from hr where location_city = '' or location_city is null;
select location_state from hr where location_state = '' or location_state is null;


########################################### DATA CLEANING #################################################################
-- rename columns
ALTER TABLE hr RENAME COLUMN ï»¿id TO id;

-- convert birthdate and hire_date to format appropriate for sql 
UPDATE hr 
SET 
  birthdate = STR_TO_DATE(birthdate, '%m/%d/%Y'),
  hire_date = STR_TO_DATE(hire_date, '%m/%d/%Y');

-- change datatypes for birthdate and hire_date to date
ALTER TABLE hr
MODIFY COLUMN birthdate DATE,
MODIFY COLUMN hire_date DATE;

-- convert termdate to format appropriate for sql 
UPDATE hr
SET termdate = DATE(LEFT(termdate, 10)) #left removes UTC, then keep values only for date (10 because 10 characters are used for date)
WHERE 
  termdate IS NOT NULL
  AND termdate != '';

-- in termdate column fill empty string with null 
UPDATE hr
SET termdate = NULL 
WHERE termdate = '';

-- change termdate datatype to date
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- Add Age column
ALTER TABLE hr 
ADD COLUMN age INT;

-- calculate employee's age and tenure
UPDATE hr 
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
