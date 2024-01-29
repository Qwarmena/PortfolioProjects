SELECT *
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4


--SELECT THE DATA TO USE
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2


---Total cases vs Total deaths
---Shows the likelihood of dying if infected by COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Germany'
ORDER BY 1,2


---Total cases vs population
---shows what percentage of population got COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE location = 'Germany'
ORDER BY 1,2


---Countries with highest infection rate per Population

SELECT Location, population, MAX(total_cases) AS HighestInfection, MAX(total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
Group by location, population
ORDER BY InfectedPercentage desc

---Creating views to store data for later visualizations
Create view InfectionRate AS
SELECT Location, population, MAX(total_cases) AS HighestInfection, MAX(total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
Group by location, population
--ORDER BY InfectedPercentage desc


---Countries with highest death count

SELECT Location, MAX(total_deaths) AS TotalDeaths
FROM CovidDeaths
WHERE Continent IS NOT NULL
Group by location
ORDER BY TotalDeaths desc


---Continent with highest death count

SELECT location, MAX(total_deaths) AS TotalDeaths
FROM CovidDeaths
WHERE Continent IS NULL
Group by location
ORDER BY TotalDeaths desc

---Creating views to store data for later visualizations
Create view DeathCounts AS
SELECT location, MAX(total_deaths) AS TotalDeaths
FROM CovidDeaths
WHERE Continent IS NULL
Group by location

---GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

---Creating views to store data for later visualizations
Create view DeathPercentages AS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date


---TOTAL Rolling PER VACCINATION
---Shows the rolling count of vaccinations (ie. adds up new vaccinations)

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) AS RollingVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3


---Creating views to store data for later visualizations
Create view RollingVaccinationCounts AS
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) AS RollingVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null



---USING CTE
---TOTAL Rolling PERCENTAGE of POPULATION PER VACCINATION
---Shows the rolling count and percentage of vaccinations (ie. adds up new vaccinations)


With PopvsVAC
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) AS RollingVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinations/Population)*100 AS PercentageofRollingVaccinations
FROM PopvsVAC



---Creating views to store data for later visualizations

Create View RollingVaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) AS RollingVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null