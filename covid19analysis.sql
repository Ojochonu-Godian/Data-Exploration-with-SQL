 /*
Covid 19  Data Exploration

Skills used: Joins, CTE's Temp Tables, Windows Functions,
Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4 

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Starting Data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY Location, date

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying of covid 19 if contacted in Nigeria

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeath
FROM PortfolioProject..CovidDeaths
WHERE location like '%nigeria%'
ORDER BY Location, date


-- Looking at Total cases vs Population
-- Percentage of population infected in Nigeria

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Poputalation_infected_percent
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
ORDER BY Location, date


-- Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 AS PopulationInfectedPercent
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
GROUP BY location, population
ORDER BY PopulationInfectedPercent DESC


-- To show countries with highest death count per population

SELECT Location, MAX(cast(total_deaths AS int)) AS DeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY DeathRate DESC

-- Drill down by Continent

-- Africa's Death Count

SELECT location, MAX(cast(total_deaths AS int)) AS DeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent like '%AFrica%'
GROUP BY location
ORDER BY DeathRate DESC

-- Continents with the highest death count

SELECT continent, MAX(cast(total_deaths AS int)) AS DeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY DeathRate DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%nigeria%'
WHERE continent is not null
ORDER BY 1, 2

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Looking at Total population by Vaccinations
-- Percentage of population that has recieved at least on covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS RollingCountofVaccinated

FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



--Using CTEs to perform calculation on partition by in previous query

with popvsvac (Continent, Location, Date, Population, New_vaccinations, RollingCountofVaccinated) 
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS RollingCountofVaccinated

FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingCountofVaccinated/Population)*100
FROM popvsvac



--with popvsvac2 (Continent, Location, Population, New_vaccinations, RollingCountofVaccinated) 
--as (
--SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
--SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location) AS RollingCountofVaccinated

--FROM PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location 
--	--AND dea.date = vac.date
--WHERE dea.continent is not null
----ORDER BY 2,3
--)

--SELECT *, (RollingCountofVaccinated/Population)*100
--FROM popvsvac2

-- Using TEMP TABLE to perform calculation on partit
Drop Table if exists #PercentageofPopulationVaccinated
CREATE Table #PercentageofPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountofVaccinated numeric
)

INSERT INTO #PercentageofPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS RollingCountofVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingCountofVaccinated/Population)*100
FROM #PercentageofPopulationVaccinated



--Creating view to store data for later visualization

CREATE VIEW PercentageofPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS RollingCountofVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentageofPopulationVaccinated



CREATE VIEW NigeriaCovidAnalysis AS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeath
FROM PortfolioProject..CovidDeaths
WHERE location like '%nigeria%'
--ORDER BY Location, date

SELECT *
FROM NigeriaCovidAnalysis


CREATE VIEW HighestDeathRateCountries AS
SELECT Location, MAX(cast(total_deaths AS int)) AS DeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY location
--ORDER BY DeathRate DESC

CREATE VIEW HighestDeathCountContinents AS
SELECT continent, MAX(cast(total_deaths AS int)) AS DeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY continent
--ORDER BY DeathRate DESC

CREATE VIEW AfricaDeathCount AS
SELECT location, MAX(cast(total_deaths AS int)) AS DeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent like '%AFrica%'
GROUP BY location
--ORDER BY DeathRate DESC

SELECT * 
FROM AfricaDeathCount
ORDER BY DeathRate DESC