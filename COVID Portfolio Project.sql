--SELECT THE DATA TO REVIEW 
SELECT *
FROM CovidDeaths
ORDER BY 3,4;
SELECT *
FROM CovidVaccinations
ORDER BY 3,4;

--Looking at Total cases VS Total Deaths
--Shows likelihood of dying if you contract Covid in India
--Used Cast funtion to convert as float to perform percentage calculation
SELECT location, date, population, total_cases, total_deaths, (Cast(total_deaths as float) / total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'India'
ORDER BY date;

--Looking at the Total Cases VS Population
--Shows likelihood of getting covid in India
--Used Cast funtion to convert as float to perform percentage calculation
SELECT location, date, population, total_cases, (CAST(total_cases as float) / population)*100 as InfectionRate
FROM CovidDeaths
WHERE location like 'India'
ORDER BY date;

--Looking at the countries with highest infection rate compared to population
--Shows location with highest infection rate
--we have to remove locations which appears to be continents instead as well
--Used Cast funtion to convert as float to perform percentage calculation
SELECT location, population, max(total_cases) as HighestInfectionCount,  max(cast(total_cases as float) / population)*100 AS HighestInfectionRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY HighestInfectionRate desc;

--Looking at countries with highest death rates
--we have to remove locations which appears to be continents instead as well
--Used Cast funtion to convert as float to perform percentage calculation
SELECT location, population, max(total_cases)as cases, max(total_deaths) as deaths, MAX(Cast(total_deaths as float) / population)*100 AS HighestDeathRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY HighestDeathRate DESC;

--Looking at countries with highest total death count
--we have to remove locations which appears to be continents instead as well
SELECT location, population, max(total_deaths) as DeathCounts
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY DeathCounts desc;

--Looking at continents and income status with highest total death count
SELECT location, population, max(total_deaths) as global_deaths
FROM CovidDeaths
WHERE continent is null
GROUP BY location,population
ORDER BY global_deaths desc;

--Looking at number of new cases and deaths per day for the entire world
SELECT date, sum(new_cases) as Dailynewcases, sum(new_deaths)as Dailynewdeaths
FROM CovidDeaths
GROUP BY date
ORDER BY date;

--Looking at number of people vaccinated in the country's population
--using windows SUM funtion to do a rolling sum of new vaccinations
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as rolling_vaccines
FROM CovidVaccinations vac
JOIN CovidDeaths dea
on vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null

--Using CTE to create table and use the field in the CTE table created to get HIghest Vaccianted Percentage for the entire world
WITH PopVsVac AS (SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as rolling_vaccines
FROM CovidVaccinations vac
JOIN CovidDeaths dea
on vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null)
SELECT continent, location, (max(rolling_vaccines) / CAST(population AS float))*100 as HighestVaccinatedRate
FROM PopVsVac
GROUP BY continent, location,population
ORDER BY HighestVaccinatedRate desc;


--Used Temp Table (returns same values as the CTE above)
--have to specify proper datatype as an example for population bigint is used because of huge numbers
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population bigint,
New_vaccination bigint,
Total_vaccination bigint)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, population, new_vaccinations,
SUM(new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
FROM CovidVaccinations vac
JOIN CovidDeaths dea
ON vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null

SELECT *, (CAST(Total_vaccination AS float)/Population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


--Creating Views to store data for Visualization later
--1
CREATE VIEW DeathPercentage AS 
SELECT location, date, population, total_cases, total_deaths, (Cast(total_deaths as float) / total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'India'

--2
CREATE VIEW InfectionRate AS 
SELECT location, date, population, total_cases, (CAST(total_cases as float) / population)*100 as InfectionRate
FROM CovidDeaths
WHERE location like 'India'

--3
CREATE VIEW GlobalInfectionRate AS 
SELECT location, population, max(total_cases) as HighestInfectionCount,  max(cast(total_cases as float) / population)*100 AS HighestInfectionRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population

--4
CREATE VIEW GlobalDeathRate AS 
SELECT location, population, max(total_cases)as cases, max(total_deaths) as deaths, MAX(Cast(total_deaths as float) / population)*100 AS HighestDeathRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population

--5
CREATE VIEW GlobalDeathCount AS
SELECT location, population, max(total_deaths) as DeathCounts
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population

--6
CREATE VIEW RollingVaccination AS
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as rolling_vaccines
FROM CovidVaccinations vac
JOIN CovidDeaths dea
on vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null

--7
CREATE VIEW PercentPopulationVaccinated AS
WITH PopVsVac AS (SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as rolling_vaccines
FROM CovidVaccinations vac
JOIN CovidDeaths dea
on vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null)
SELECT continent, location, (max(rolling_vaccines) / CAST(population AS float))*100 as HighestVaccinatedRate
FROM PopVsVac
GROUP BY continent, location,population




