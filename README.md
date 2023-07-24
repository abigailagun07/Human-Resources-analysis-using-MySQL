# Human-Resources-data-analysis-using-MySQL
This project conducts exploratory data analysis on a company's human resources dataset using SQL queries.
The analysis provides a thorough overview of the company's employee profile and trends. The SQL code can serve as a template for conducting human resources analytics.

## Data
The dataset contains 22,215 rows with information on employees, including:
- ID
- First name
- Last name
- Birthdate
- Gender
- Race
- Department 
- Job title
- Location
- Hire date
- Term date
- Location city
- Location state

The data is stored in a MySQL database called `human_resources`.

## Analysis
The SQL scripts perform analysis on the HR data across four main categories:

### A. Demographics
- Gender distribution
- Race/ethnicity distribution
- Age range and distribution
- Breakdown of gender and race

### B. Location
- Onsite vs remote employees
- Distribution across states
- Distribution across cities

### C. Department
- Distribution across departments
- Distribution of job titles
- Gender breakdown per department
- Identification of female-dominated departments/roles

### D. Tenure 
- Average tenure for terminated employees
- Average tenure per department
- Turnover rate by department and job title
- Headcount change over time

## Scripts
`data_cleaning.sql`
- Renames columns
- Converts date columns to appropriate SQL date format
- Fills in missing values
- Adds computed column for age

`data_analysis.sql`
- Contains all the SQL queries to generate the analysis and insights on demographics, location, department, and tenure

## Key Insights
- Most employees are male, white, and in their 30s
- Vast majority of staff work onsite at the Cleveland HQ
- Engineering department is the largest 
- Most roles have more men than women
- Average tenure is 8 years for terminated employees
- Auditing has the highest turnover rate
