#Total_cases vs Population
#(Shows what percentage of the country's population had covid on a particular day)
SELECT
location,
str_to_date(DATE,'%d-%m-%Y'),
total_cases,
population, 
(total_cases/population)*100 AS percentage_infected
FROM covid_deaths 
WHERE location="India"
ORDER BY location, str_to_date(DATE,'%d-%m-%Y');


#Location vs Total Deaths
#(Shows the country wise likelihood (here, for India) of death after contracting covid per day)
SELECT
location,
str_to_date(DATE,'%d-%m-%Y'),
total_cases,
total_deaths, 
(total_deaths/total_cases)*100 AS percentage_deaths
FROM covid_deaths 
WHERE location="India"
ORDER BY location, str_to_date(DATE,'%d-%m-%Y');


#Countries with higest percentage of their popuation infected on a given day
SELECT
location,
population,
MAX(total_cases) max_cases_per_day,
MAX((total_cases/population))*100 AS highest_percentage_infected_per_day
FROM covid_deaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_percentage_infected_per_day DESC;

#Total Death Count per Country
SELECT
location,
population,
SUM(total_deaths) all_deaths,
(SUM(total_deaths)/population)*100 AS total_percentage_died
FROM covid_deaths 
WHERE continent != ""  #to ensure we don't get continent wise data
GROUP BY location
ORDER BY all_deaths DESC, total_percentage_died DESC;

#Total Death Count per Continent
SELECT
location,
population,
SUM(total_deaths) all_deaths,
(SUM(total_deaths)/population)*100 AS total_percentage_died
FROM covid_deaths  
WHERE continent = ""
GROUP BY location
ORDER BY all_deaths DESC, total_percentage_died DESC;


#Worldwide accumulation of deaths and cases per day
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS percentage_deaths
FROM covid_deaths
WHERE continent !=""
GROUP BY date
ORDER BY total_cases, total_deaths;


#Total Population vs Vaccinations
#Using CTE (Common Table Expressions)
WITH population_vs_vaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent !=""
)
SELECT *, (rolling_people_vaccinated/population)*100  AS percent_vaccinated_till_date FROM population_vs_vaccination;


#TEMP Table
DROP TABLE IF EXISTS percent_dying_everyday;

CREATE TABLE percent_dying_everyday ( 
continent nvarchar(255), 
location nvarchar(255), 
date date, 
population bigint, 
new_deaths varchar(500), 
rolling_people_dying bigint);

INSERT INTO percent_dying_everyday
SELECT continent, location, date, population, new_deaths,
SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_dying
FROM covid_deaths cd
WHERE continent !="";

SELECT *, (rolling_people_dying/population)*100 percent_dead_till_date FROM percent_dying_everyday;


#Creating a view for later visualizations in Tableau

CREATE VIEW percent_dying_everyday_view AS
SELECT continent, location, date, population, new_deaths,
SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_dying
FROM covid_deaths cd
WHERE continent !="";

CREATE VIEW percent_vaccinated_till_date_view AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent !="";