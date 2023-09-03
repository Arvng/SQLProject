-- 1. Total number of Deaths and Cases recorded
SELECT
    MAX(total_cases) AS TotalCases,
    MAX(total_deaths) AS Totaldeaths,
    Location
FROM covid_death
WHERE location IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY Totaldeaths, TotalCases;

CREATE VIEW DeathsAndCases AS
(
    SELECT
        MAX(total_cases) AS TotalCases,
        MAX(total_deaths) AS Totaldeaths,
        Location
    FROM covid_death
    WHERE location IS NOT NULL AND continent IS NOT NULL
    GROUP BY location
);

-- 2. Total number of Covid cases #YEAR ad #continent wise - using CTE
-- Create a Common Table Expression (CTE) named Maxtoalcasesinayear
WITH Maxtoalcasesinayear (Location, covid_year, continent, total_cases) AS (
    SELECT
        Location,
        YEAR(dateconverted) AS Covid_year,
        continent,
        Total_cases
    FROM
        covid_death
    WHERE
        continent IS NOT NULL
        AND total_cases IS NOT NULL
)

/*-- Created a view named Maxtoalcasesinayear-this table can be used to get total number of covid cases for the year 2020, 2021,2022 and 2023
and can be used to get total number covid cases by continent in each year--*/

CREATE VIEW Maxtoalcasesinayear AS
WITH Maxtoalcasesinayear(Location, covid_year, continent, total_cases) AS (
    SELECT
        Location,
        YEAR(dateconverted) AS Covid_year,
        continent,
        Total_cases
    FROM
        covid_death
    WHERE
        continent IS NOT NULL
        AND Total_cases IS NOT NULL
)
-- Example: Select the desired columns and calculate the maximum total COVID-19 cases in a year--
SELECT
    Covid_year,
    Location,
    continent,
    MAX(total_cases) AS total_covid_cases_inayear
FROM
    Maxtoalcasesinayear
GROUP BY
    Covid_year,
    Location,
    continent;


-- 3. What percentage of population got infected
SELECT
    MAX(total_cases) AS Highest_infected_country,
    country_Population,
    Location,
    MAX((total_cases / country_Population)) * 100 AS Percentage_Populationinfected
FROM covid_death
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY Location, country_population
ORDER BY Highest_infected_country;

CREATE VIEW PopInfectionPerc AS
(
    SELECT
        MAX(total_cases) AS Highest_infected_country,
        country_Population,
        Location,
        MAX((total_cases / country_Population)) * 100 AS Percentage_Populationinfected
    FROM covid_death
    WHERE continent IS NOT NULL AND total_cases IS NOT NULL
    GROUP BY Location, country_population
);

-- 4. Total/Highest Death recorded by Location
SELECT
    MAX(total_deaths) AS Total_no_of_death,
    Location
FROM covid_death
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY Location
ORDER BY Total_no_of_death DESC;

CREATE VIEW HighestDeathCountry AS
(
    SELECT
        MAX(total_deaths) AS Total_no_of_death,
        Location
    FROM covid_death
    WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
    GROUP BY Location
);

-- 5. Highest/Total Death recorded by continent
SELECT
    MAX(total_deaths) AS Total_no_of_death,
    continent
FROM covid_death
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY continent
ORDER BY Total_no_of_death DESC;

CREATE VIEW HighestDeathCont AS
(
    SELECT
        MAX(total_deaths) AS Total_no_of_death,
        continent
    FROM covid_death
    WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
    GROUP BY continent
);

-- 6. Total number of new cases registered in a day and total number of death registered in a day
SELECT
    date,
    SUM(CAST(new_cases AS INT)) AS New_cases,
    total_deaths
FROM covid_death
GROUP BY date, total_deaths
ORDER BY New_cases, Total_deaths ASC;

CREATE VIEW DailyCasesDeaths AS
(
    SELECT
        date,
        SUM(CAST(new_cases AS INT)) AS New_cases,
        total_deaths
    FROM covid_death
    GROUP BY date, total_deaths
);

-- 7. Overall Case recorded, Death recorded, World's Population, and Death Percentage
WITH Overall_Covid_data(Total_Population, Death_recorded, case_recorded, Location, continent) AS
(
    SELECT
        MAX(country_population) AS Total_Population,
        MAX(Total_deaths) AS Death_recorded,
        MAX(total_cases) AS case_recorded,
        Location,
        continent
    FROM covid_death
    WHERE continent IS NOT NULL AND location IS NOT NULL
    GROUP BY location, continent
)
SELECT
    SUM(case_recorded) AS Cases_recorded,
    SUM(Death_recorded) AS Death_recorded,
    SUM(Total_Population) AS Worlds_Population,
    (SUM(Death_recorded) / SUM(Total_Population)) * 100 AS Death_percentage
FROM Overall_Covid_data;

CREATE VIEW OverallStats AS
    WITH Overall_Covid_data(Total_Population, Death_recorded, case_recorded, Location, continent) AS
    (
        SELECT
            MAX(country_population) AS Total_Population,
            MAX(Total_deaths) AS Death_recorded,
            MAX(total_cases) AS case_recorded,
            Location,
            continent
        FROM covid_death
        WHERE continent IS NOT NULL AND location IS NOT NULL
        GROUP BY location, continent
    )
    SELECT
        SUM(case_recorded) AS Cases_recorded,
        SUM(Death_recorded) AS Death_recorded,
        SUM(Total_Population) AS Worlds_Population,
        (SUM(Death_recorded) / SUM(Total_Population)) * 100 AS Death_percentage
    FROM Overall_Covid_data


-- 8. First Vaccination, People fully vaccinated grouped by Country
WITH First_and_Fully_Vaccinated(Location, First_vaccinated_Jab, Fully_vaccinated) AS
(
    SELECT
        Location,
        Max(Total_Vaccinations) OVER(PARTITION BY Location) AS First_vaccinated_Jab,
        Max(people_fully_vaccinated) OVER(PARTITION BY Location) AS Fully_vaccinated
    FROM covidvaccination
    WHERE location IS NOT NULL AND continent IS NOT NULL
)
SELECT
    MAX(First_vaccinated_Jab) AS First_vaccination_Jab,
    MAX(Fully_vaccinated) AS People_Fullyvaccinated,
    Location
FROM First_and_Fully_Vaccinated
GROUP BY Location;

CREATE VIEW FirstVaccCountry AS

    WITH First_and_Fully_Vaccinated(Location, First_vaccinated_Jab, Fully_vaccinated) AS
    (
        SELECT
            Location,
            Max(Total_Vaccinations) OVER(PARTITION BY Location) AS First_vaccinated_Jab,
            Max(people_fully_vaccinated) OVER(PARTITION BY Location) AS Fully_vaccinated
        FROM covidvaccination
        WHERE location IS NOT NULL AND continent IS NOT NULL
    )
    SELECT
        MAX(First_vaccinated_Jab) AS First_vaccination_Jab,
        MAX(Fully_vaccinated) AS People_Fullyvaccinated,
        Location
    FROM First_and_Fully_Vaccinated
    GROUP BY Location


-- 9. First Vaccination, People fully vaccinated grouped by continent
WITH First_and_Fully_ContVaccinated(continent, First_vaccinated_Jab, Fully_vaccinated) AS
(
    SELECT
        continent,
        Max(Total_Vaccinations) OVER(PARTITION BY continent) AS First_vaccinated_Jab,
        Max(people_fully_vaccinated) OVER(PARTITION BY continent) AS Fully_vaccinated
    FROM covidvaccination
    WHERE location IS NOT NULL AND continent IS NOT NULL
)
SELECT
    MAX(First_vaccinated_Jab) AS First_vaccination_Jab,
    MAX(Fully_vaccinated) AS People_Fullyvaccinated,
    continent
FROM First_and_Fully_ContVaccinated
GROUP BY continent;

CREATE VIEW FirstVaccCont AS
    WITH First_and_Fully_ContVaccinated(continent, First_vaccinated_Jab, Fully_vaccinated) AS
    (
        SELECT
            continent,
            Max(Total_Vaccinations) OVER(PARTITION BY continent) AS First_vaccinated_Jab,
            Max(people_fully_vaccinated) OVER(PARTITION BY continent) AS Fully_vaccinated
        FROM covidvaccination
        WHERE location IS NOT NULL AND continent IS NOT NULL
    )
    SELECT
        MAX(First_vaccinated_Jab) AS First_vaccination_Jab,
        MAX(Fully_vaccinated) AS People_Fullyvaccinated,
        continent
    FROM First_and_Fully_ContVaccinated
    GROUP BY continent


-- 10. Total number of People Vaccinated and Total Population of the country
SELECT
    MAX(CV.[people_fully_vaccinated]) AS People_vaccinated,
    CD.location,
    CD.continent,
    CD.country_Population
FROM sql_project..Covid_death CD
JOIN sql_project..Covidvaccination CV ON CD.Location = CV.Location
WHERE CV.continent IS NOT NULL
GROUP BY CD.location, CD.country_Population, CD.continent
ORDER BY people_vaccinated DESC;

CREATE VIEW VaccPopByCountry AS
(
    SELECT
        MAX(CV.[people_fully_vaccinated]) AS People_vaccinated,
        CD.location,
        CD.continent,
        CD.country_Population
    FROM sql_project..Covid_death CD
    JOIN sql_project..Covidvaccination CV ON CD.Location = CV.Location
    WHERE CV.continent IS NOT NULL
    GROUP BY CD.location, CD.country_Population, CD.continent
);

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

The reason to use CTE and View function for the "2" Query is when i tried to filter Maximum number of cases in a country in a given year i received
 error "Operand type clash: date is incompatible with smallint"
This was my test code
----------------------------
/* select Location, year(cast(dateconverted as date)) as Covid_year, total_cases from covid_death
where location = 'Afghanistan' and dateconverted=2021
-----------------------------
To fix this, after a small research I wrote this code 
SELECT Location, YEAR(dateconverted) AS Covid_year, total_cases
FROM covid_death
WHERE Location = 'Afghanistan'
  AND dateconverted >= '2021'  -- Start of 2021
  AND dateconverted <= '2022' --- End of 2021 */
----------------------------
I got the result, but I didn't get maximum number of cases recorded in a country, 
    instead the result was complete list of cases recorded each day ..so I used CTE and View to bring the result.
----------------------------
I got the_result, but i didn't get maximum number of cases recorded in a country, 
    instead the result was compelte list of cases recorded each day ..so I used CTE and View to bring the result.


