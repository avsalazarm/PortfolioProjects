/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Select data to be used 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in Canada

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Canada%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Canada%' AND continent IS NOT NULL
ORDER BY 1,2


-- Look at countries with highest infection rates compared to population

SELECT 
	location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX(ROUND((total_cases/population)*100,2)) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC


-- Show countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING IT DOWN BY CONTINENTS

-- Show continents with the highest death count per population

-- Correct Query
-- SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
-- FROM PortfolioProject..CovidDeaths
-- WHERE continent IS NULL
-- GROUP BY location
-- ORDER BY TotalDeathCount DESC

-- For visualization purposes

SELECT continent AS Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	ROUND(SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS VaccinatedPercentage
FROM PopVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS VaccinatedPercentage
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


-- View visualization
SELECT *
FROM PercentPopulationVaccinated
