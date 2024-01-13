SELECT *
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--select data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total cases VS Total deaths
-- Chances of dying in one country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathspercent
FROM portfolioproject..CovidDeaths
WHERE Location LIKE '%India%' AND continent IS NOT NULL
ORDER BY 1,2


-- Total cases VS Population
-- shows percentage of people got covid

SELECT Location, date, total_cases, population, (total_cases/population) *100 as populationwithcovid
FROM portfolioproject..CovidDeaths
--WHERE Location LIKE '%India'
WHERE continent IS NOT NULL
ORDER BY 1,2



-- countries with highest covid rate compared to population

SELECT Location, population, MAX(total_cases) as Highestcovidrate, MAX((total_cases/population))*100 as percentpopgotcovid
FROM portfolioproject..CovidDeaths
--WHERE Location LIKE '%India'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY percentpopgotcovid DESC



-- Highest Deaths count per population

SELECT Location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
--WHERE Location LIKE '%India'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- By Continent
-- continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
--WHERE Location LIKE '%India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC




-- Entire world 

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/ SUM(new_cases)*100 AS DeathPercent
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Peoplevaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
   ON dea.Location = vac.Location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- To use the column that we created in table
-- using CTE

WITH PopvsVac (continent, location, date,population,new_vaccinations, Peoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Peoplevaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
   ON dea.Location = vac.Location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(Peoplevaccinated/population)*100
FROM PopvsVac


-- creating view for visualization

CREATE VIEW percentpeoplevaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Peoplevaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
   ON dea.Location = vac.Location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


-- view

SELECT *
FROM percentpeoplevaccinated