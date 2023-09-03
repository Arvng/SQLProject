# SQLProject
Link to data set https://ourworldindata.org/covid-deaths

/* data cleaning */

******Date Conversion*******
-- Select [DATE]_>column and convert it for display
SELECT [DATE], CONVERT(date, [date]) AS DateConverted
FROM covid_death;

-- Alter the table to add a new column named DateConverted
ALTER TABLE covid_death
ADD DateConverted date;

-- Update the DateConverted column with correctly formatted dates
UPDATE covid_death
SET DateConverted = CONVERT(date, [date]);

alter table covid_death
alter column total_deaths float

alter table covid_death
alter column total_cases float

alter table covid_death
alter column country_population float

delete from covid_death
where location = 'lower middle income'

delete from covid_death
where location = 'upper middle income'

delete from covid_death
where location = 'low income'

delete from covid_death
where location = 'high income'

delete from covidvaccination
where people_fully_vaccinated is null

delete from covid_death
where location = 'world'

sp_rename 'covid_Death.population', 'country_Population' 
/*    
Notes:
1.The ORDER BY clause is invalid in views
, inline functions, derived tables, subqueries, and common table expressions
, unless TOP, OFFSET or FOR XML is also specified.

2.To execute the query I have removed the parentheses that were originally surrounding the CTE definition 
after the AS keyword in the CREATE VIEW statement

3. I have amended the code for
      #2" Total number of Covid cases #year and #continet wise"

**The reason to use CTE and View function for the "2" Query is when i tried to filter Maximum number of cases in a country in a given year i received
 error "Operand type clash: date is incompatible with smallint"

This was my test code
----------------------------
/* select Location, year(cast(dateconverted as date)) as Covid_year, total_cases from covid_death
where location = 'Afghanistan' and dateconverted=2021
-----------------------------
To fix this, after a small research I wrote this code 

------------------------------
SELECT Location, YEAR(dateconverted) AS Covid_year, total_cases
FROM covid_death
WHERE Location = 'Afghanistan'
  AND dateconverted >= '2021'  -- Start of 2021
  AND dateconverted <= '2022' --- End of 2021 */
----------------------------

I got the result, but I didn't get maximum number of cases recorded in a country, 
    instead the result was complete list of cases recorded each day ..so I used CTE and View to bring the result.**

