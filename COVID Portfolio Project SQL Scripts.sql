Select * 
FROM PortfolioProject..CovidDeaths$
Order by 3, 4

--Selects the data to be used
Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2 

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Philippines'
ORDER BY 1,2 

--Total Cases vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Philippines'
ORDER BY 1,2 

--Looking at Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as PositivePercentage
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PositivePercentage DESC

--Showing countries with the Highest Death Count per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Break things down by Continent
--Shows continents with the highest death counts 
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--Group By date
ORDER BY 1,2 



SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population Vs. Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
--	, MAX(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE

With PopVsVac(Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
--	, MAX(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

-- TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
--	, MAX(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfRollingPeopleVaccinated
From #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
--	, MAX(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
