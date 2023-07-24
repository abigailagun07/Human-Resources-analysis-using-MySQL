-- Disable safe mode
SET GLOBAL sql_safe_updates=0; 

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
select termdate from hr where termdate= '' or termdate is null; #empty string values present termdate
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

############################################### DATA ANALYSIS #################################################

#### A: Demographics
-- 1. what is the gender distribution of the employees?
SELECT gender, COUNT(*) as gender_count
FROM hr
WHERE termdate IS NULL or termdate >= curdate() #this condition was set to ensure query on returns employees who are still in employment.
GROUP BY gender;  
#INSIGHT: returns 10100 male, 9196 female and 546 non-conforming- indicate more male employees.

-- 2. What is the race/ethnicity distribution of the employee?
SELECT race, COUNT(*) as race_count
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY race
ORDER BY race_count DESC; 
/* INSIGHT: Most employees are white (5657) followed by employees with two or more race (3256), 
least is native-hawaiian or other pacific islander */

-- 3. What is the age range and distribution of the employees.
SELECT MIN(age) as min_age, MAX(age) as max_age, CEILING(AVG(age)) as avg_age
FROM hr
WHERE termdate IS NULL or termdate >= curdate(); 
#INSIGHT: employee's age range from 20 - 57, average age is 39

SELECT CASE
			WHEN age BETWEEN 20 AND 29 THEN '20s'
            WHEN age BETWEEN 30 AND 39 THEN '30s'
            WHEN age BETWEEN 40 AND 49 THEN '40s'
            ELSE '50s'
		END AS age_group,
        count(*) as num_of_employees
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY age_group
ORDER BY num_of_employees DESC; 
#INSIGHT: Most employees are in their 30s(returns 5474) while there are few employees in their 50s (retuns 4174)

-- 4. What is the gender and race distribution 
SELECT gender, race, count(*) AS emp_gender_n_race
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY gender, race
ORDER BY gender;
/* INSIGHT: for Male and female highest race is white, followed by emp with two or more races
and the least being Native Hawaiian or other pacific islander. However for non-conforming black 
or african american is the second most common race */


#### B: LOCATION
-- 1. How many employees work onsite or remotely?
SELECT location, COUNT(*) AS num_of_employees
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY(location); 
#INSIGHT: most people work in the headquaters (14898), 4943 work remotely.

-- 2. What is the distribution of employees in state 
SELECT location_state, COUNT(*) as num_of_employees
FROM hr 
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY location_state
ORDER BY num_of_employees DESC; 
#INSIGHT: majority work in ohio (16073), least is Wisconsin (343)

-- 3. What is the distribution of employees in each city?
SELECT location_city, COUNT(*) as num_of_employees
FROM hr 
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY location_city
ORDER BY num_of_employees DESC; 
#INSIGHT: most work in cleveland (15041) , only 8 employees work in Frankfort

-- ### out of curiosity are there other ohio city people work in? 
SELECT DISTINCT(location_city) 
FROM hr 
WHERE termdate IS NULL or termdate >= curdate()
AND location_state = 'Ohio';
/* INSIGHT: YES- so cleveland is not the only place in Ohio the employees work at.
 A quick google search however indicated its is densely populated */


#### C: DEPARTMENT
-- 1. What is the distribution of employees in each department?.
SELECT department, COUNT(*) as employee_per_department
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY department
ORDER BY employee_per_department DESC; 
/*INSIGHT: Most people work in the engineering department (5964), 
followed by accounting (2976), least being Auditing (44). */

-- 2. What is the jobtitle distribution?
SELECT jobtitle, count(*) AS num_of_employees
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY jobtitle
ORDER BY num_of_employees DESC;
/*INSIGHT: Most people work as Research Assistant II (692) followed by Business Analyst (633),
least being Marketing Manager, Executive Secretary, Associate professor, VP of training and development,
office assisant IV and Assistant Professor as only one employee was counted. */

-- 3. What is the gender distribution of each department?
SELECT department, gender, COUNT(*) AS department_by_gender
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY department, gender
ORDER BY department;
#INSIGHT: Most department are dominated my men

-- 4. Any department where there are more female than male?
SELECT department, COUNT(*) AS num_occurrences
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY department
HAVING SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) > SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END); 
#INSIGHT: no department had more female than men.

-- 5. Any jobtitle where there are more female than male?
SELECT jobtitle
FROM hr
WHERE termdate IS NULL or termdate >= curdate()
GROUP BY jobtitle
HAVING SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) > SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END);
#INSIGHT: yes- there are some jobtitle that female dominate more than men.


#### D: TENURE
-- 1. What is the average length of employment for those terminated?
SELECT ROUND(AVG((DATEDIFF(termdate, hire_date))/365),0) as avg_length_of_employment
FROM hr
WHERE termdate IS NOT NULL and termdate <= CURDATE();
#INSIGHT: Average length of employment is 8 years

-- 2. What is the average length of employement for each department?
SELECT department, ROUND(AVG((DATEDIFF(termdate, hire_date))/365),0) as avg_length_of_employment
FROM hr
WHERE termdate IS NOT NULL and termdate <= CURDATE()
GROUP BY department
ORDER BY avg_length_of_employment;
#INSIGHT: product management department has the least length of average employment.

## TURNOVER
-- 1. What is the turnover rate of each department?
SELECT department, COUNT(*) as total_employees, 
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS end_of_term, 
    SUM(CASE WHEN termdate IS NOT NULL OR termdate <= curdate() THEN 1 ELSE 0 END) AS ongoing_contract,
    ROUND((SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*) * 100),0) as "percentage_of_termination_rate"
FROM hr
GROUP BY department
ORDER BY percentage_of_termination_rate DESC;
/*INSIGHT: Auditing department has the highest turnover (15) followed by the Legal department (13). 
Business development and Marketing has the least turn over (9) */


 -- 2. What is the turnover rate of each Jobtitle?
SELECT jobtitle, COUNT(*) as total_employees, 
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS end_of_term, 
    SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END) AS ongoing_contract,
    ROUND((SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*) * 100),1) as percentage_of_termination_rate
FROM hr
GROUP BY jobtitle
ORDER BY percentage_of_termination_rate DESC;
#INSIGHT: Office Assistant II had the highest termination rate but it is worth noting that there is one one employee with this jobtitle


-- 3. How has headcount changed over time identify change in overhead
CREATE VIEW hires AS
SELECT DATE_FORMAT(hire_date, '%Y') AS hire_year,
       COUNT(*) AS new_hires
FROM hr
GROUP BY DATE_FORMAT(hire_date, '%Y')
ORDER BY hire_year;

CREATE VIEW alumni AS
SELECT DATE_FORMAT(termdate, '%Y') AS alumni_year,
       COUNT(*) AS alumni_count
FROM hr
WHERE termdate <= CURDATE()
GROUP BY DATE_FORMAT(termdate, '%Y')
ORDER BY alumni_year;

DROP VIEW alumni;
select * from alumni;

SELECT h.hire_year AS year_hired,
       h.new_hires - a.alumni_count AS employee_change,
       ROUND((h.new_hires - a.alumni_count) / h.new_hires * 100, 2) AS percentage_change
FROM hires h
LEFT JOIN alumni a
ON h.hire_year = a.alumni_year
UNION
SELECT a.alumni_year AS year_employee_left,
       h.new_hires - a.alumni_count AS employee_change,
       ROUND((h.new_hires - a.alumni_count) / h.new_hires * 100, 2) AS percentage_change
FROM hires h
RIGHT JOIN alumni a
ON h.hire_year = a.alumni_year
ORDER BY year_hired,percentage_change DESC;
/*INSIGHT: there was no employee change in 2000 and years after 2021 meaning no employee terminated during this years. 
of the years employees terminated, 2001 had the highest. */