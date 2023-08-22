select * from covid_death
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, country_Population from covid_death
order by 1,2  ---order by 1,2 is given to sort the location Alphabetically or we can even use the regular order by clause i.e order by location.


--Looking for total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage from covid_death
where total_cases is not null
order by Death_Percentage asc


--Looking for total cases vs total deaths in Inida
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage from covid_death
where total_cases is not null and location='India'
order by Death_Percentage asc

--What percentage of population got infected by covid-- not using aggreate fuction
select Location, date, total_cases, [country_Population], (total_cases/[country_Population])*100 as Infected_Percentage from covid_death
where total_cases is not null
order by Infected_Percentage desc

--highest percentage of population got infected--using aggregate function
--excluding null values
select max(total_cases) as Highest_infected_country, country_Population, Location, max((total_cases/country_Population))*100 as Percentage_Populationinfected from covid_death
where continent is not null and total_cases is not null
group by Location, country_population
order by Highest_infected_country desc

---Total Death Count by Location using aggregate function, where, group by and order by clause

select MAX(total_deaths) as Total_no_of_death, Location from covid_death
where total_deaths is not null and continent is not null
group by Location
order by Total_no_of_death desc

---Highest/Total Death Count by continent using aggregate function, where, group by and order by clause
select MAX(total_deaths) as Total_no_of_death, continent from covid_death
where total_deaths is not null and continent is not null 
group by continent
order by Total_no_of_death desc

----Total number of new cases registered in a day and total number of death registered in a day.

select date, SUM(cast(new_cases as int)) as New_cases,total_deaths from covid_death
group by date, total_deaths
order by new_cases, Total_deaths asc

--overall Case recorded, Death recorded, Worlds Population and Death Percentage.

select SUM(total_cases) as Cases_recorded, SUM(total_deaths) as Death_recorded, SUM(country_Population) as Worlds_Population, 
(sum(Total_deaths)/sum(country_Population))*100 as Death_percentage from covid_death

/* COVID VACCINATIONS*/


SELECT mEDIAN_AGE, aged_65_older, aged_70_older, Total_vaccinations,Total_boosters, continent, Location from [dbo].[covidvaccination]
WHERE TOTAL_VACCINATIONS IS NOT NULL

---Total Vaccination, Booster shots grouped by continents

SELECT SUM(CAST(Total_vaccinations AS bigint)) AS WORLDS_VACCINATION, SUM(CAST(Total_boosters AS bigint)) AS WORLDS_TO_NO_BOOSTER,
continent from [dbo].[covidvaccination]
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT

---Joins
select * from covid_death as CD
join covidvaccination as CV
on CD.location=CV.location 
and CD.date = CV.date


----Looking for total vaccination  and  population

select CD.location,CD.date,CD.continent,CD.country_Population, CV.total_vaccinations from covid_death as CD
join covidvaccination as CV
on CD.location=CV.location 
and CD.date = CV.date
where CD.continent is not null
order by CV.total_vaccinations

-------------New vaccination and Up to date Vaccination by location

select CD.location,CD.date,CD.continent,CD.country_Population, CV.new_vaccinations, 
SUM(cast(CV.New_vaccinations as bigint)) over (PARTITION by CD.location order by CD.location,CD.date) as UTDVaccination  from covid_death as CD
join covidvaccination as CV
on CD.location=CV.location 
and CD.date = CV.date
where CD.continent is not null


----Total New vaccination against population

select CD.location,CD.date,CD.continent,CD.country_Population, CV.new_vaccinations,
sum(cast(CV.new_vaccinations AS float))/SUM(CD.Country_population)*100 as Vaccination_percentage from covid_death as CD
join covidvaccination as CV
on CD.location=CV.location 
and CD.date = CV.date
where CD.continent is not null
Group by cd.location, CD.date, CD.continent,CD.country_Population,CV.new_vaccinations
order by Vaccination_percentage

----Total New vaccination against population
-----CTE
 
with Popvsvac (continent,Location, date, country_Population,new_vaccinations, current_vaccination)
as (
select CD.location,CD.continent, cd.date, CD.country_Population, CV.new_vaccinations,
sum(convert(bigint,CV.new_vaccinations)) over (partition by CD.location order by CD.location,cd.date) as current_Vaccination
from sql_project..covid_death CD
join sql_project..covidvaccination CV
on CD.location=CV.location
and CD.date=CV.date
where CD.continent is not null
)
select *, (current_vaccination/country_Population)*100 as percent_of_vaccination from Popvsvac

---creating view to store data for visulaization

create view Worlds_vaccination_percentage 
as
select CD.location,CD.continent, cd.date, CD.country_Population, CV.new_vaccinations,
sum(convert(bigint,CV.new_vaccinations)) over (partition by CD.location order by CD.location,cd.date) as current_Vaccination
from sql_project..covid_death CD
join sql_project..covidvaccination CV
on CD.location=CV.location
and CD.date=CV.date
where CD.continent is not null

select * from [dbo].[Worlds_vaccination_percentage]

drop view [dbo].[Worlds_vaccination_percentage]

/* data cleaning 

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

delete from covid_death
where location = 'world'

sp_rename 'covid_Death.population', 'country_Population' 

*/

