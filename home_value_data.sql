# General Info
SELECT COUNT (*)
FROM df;

# How many distinct zip codes are in this dataset?
SELECT COUNT(DISTINCT zip_code) AS 'Number of Unique Zip Codes'
FROM df;

# How many zip codes are from each state?
SELECT state AS 'State', COUNT(DISTINCT zip_code) AS 'Number of zip codes per state'
FROM df
GROUP BY state
ORDER BY 2 DESC;

# What range of years are represented in the data?
SELECT DISTINCT (SUBSTR(date, 1, 4)) AS 'Years'
FROM df;

# What is the range of estimated home values across the nation?
SELECT ROUND(MIN(value),2) AS 'Minimum Home Value', ROUND(MAX(value),2) AS 'Maximum Home Value'
FROM df
WHERE date = '2018-11';

# Which states have the highest average home values?
SELECT state AS 'State', ROUND(AVG(value),2) AS 'Avg Price per State'
FROM df
WHERE date = '2018-11'
GROUP BY state
ORDER BY 2 DESC
LIMIT 5;

# How about the lowest?
SELECT state AS 'State', ROUND(AVG(value),2) AS 'Avg Price per State'
FROM df
WHERE date = '2018-11'
GROUP BY state
ORDER BY 2 ASC
LIMIT 5;

# Which states have the highest average home values for the year of 2017?
SELECT state AS 'State', ROUND(AVG(value),2) AS 'Avg Price per State'
FROM df
WHERE date LIKE '2017-%'
GROUP BY state
ORDER BY 2 DESC
LIMIT 5;

# Which states have the lowest average home values for the year of 2017?
SELECT state AS 'State', ROUND(AVG(value),2) AS 'Avg Price per State'
FROM df
WHERE date LIKE '2017-%'
GROUP BY state
ORDER BY 2 ASC
LIMIT 5;

# What is the percent change in average home values from 2007 to 2017 by state?
WITH table1 AS(
SELECT state, ROUND(AVG(value)) AS OLD_VALUE
FROM df
WHERE date LIKE '2007-%'
GROUP BY 1),
table2 AS(
SELECT state, ROUND(AVG(value)) AS NEW_VALUE
FROM df
WHERE date LIKE '2017-%'
GROUP BY 1)
SELECT table1.state, ROUND((((NEW_VALUE - OLD_VALUE)/OLD_VALUE)*100)) AS 'Percent Change'
FROM table1, table2
GROUP BY 1
ORDER BY 2 DESC;

# How about from 1997 to 2017?
WITH table1 AS(
SELECT state, ROUND(AVG(value)) AS OLD_VALUE
FROM df
WHERE date LIKE '1997-%'
GROUP BY 1),
table2 AS(
SELECT state, ROUND(AVG(value)) AS NEW_VALUE
FROM df
WHERE date LIKE '2017-%'
GROUP BY 1)
SELECT table1.state, ROUND((((NEW_VALUE - OLD_VALUE)/OLD_VALUE)*100)) AS 'Percent Change'
FROM table1, table2
GROUP BY 1
ORDER BY 2 DESC;

# How would you describe the trend in home values for each state from 1997 to 2017?
# How about from 2007 to 2017? Which states would you recommend for making real estate investments?
WITH table1 AS (SELECT state, AVG(value) AS baseYear
FROM df
WHERE date LIKE '1997-%'
GROUP BY 1),

table2 AS (SELECT state, AVG(value) AS testYear
FROM df
WHERE date LIKE '2017-%'
GROUP BY 1),

table3 AS (SELECT table1.state, ROUND(((testYear / baseYear)*100)-100, 2) AS Trend
FROM table1, table2
GROUP BY 1)

SELECT state, Trend,
CASE
WHEN Trend > 150 THEN 'Recommended'
ELSE 'Not Recommended'
END AS 'Verdict'
FROM table3
GROUP BY 1
ORDER BY 2 DESC;

# Join the house value data with the table of zip-code level census data.
# Do there seem to be any correlations between the estimated house values and characteristics of the area, such as population count or median household income?
WITH table1 AS(
SELECT state_code AS 'State', SUM(pop_total) AS 'Total Pop of State', ROUND(AVG(median_household_income)) AS 'Median Household Income'
FROM census_data
GROUP BY 1
),
table2 AS (
SELECT state AS 'State', ROUND(AVG(value),2) AS 'Avg Home Value per State'
FROM df
WHERE date = '2018-11'
GROUP BY state
)
SELECT table1.State, table1.'Total Pop of State', table1.'Median Household Income', table2.'Avg Home Value per State'
FROM table1
JOIN table2
	ON table1.State = table2.State
ORDER BY 3 DESC
LIMIT 10;
## *Observation* ##
# There is a slight correlation between median income and average home value

WITH table1 AS(
SELECT state_code AS 'State', SUM(pop_total) AS 'Total Pop of State', ROUND(AVG(median_household_income)) AS 'Median Household Income'
FROM census_data
GROUP BY 1
),
table2 AS (
SELECT state AS 'State', ROUND(AVG(value),2) AS 'Avg Home Value per State'
FROM df
WHERE date = '2018-11'
GROUP BY state
)
SELECT table1.State, table1.'Total Pop of State', table1.'Median Household Income', table2.'Avg Home Value per State'
FROM table1
JOIN table2
	ON table1.State = table2.State
ORDER BY 2 DESC
LIMIT 10;
## *Observation* ##
# Total population of the state doesn't affect average home value
