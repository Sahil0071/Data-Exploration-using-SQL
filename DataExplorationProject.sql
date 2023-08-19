SELECT *
FROM [CovidDeaths (1)]
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Shows likelihood of dying from Covid in the selected country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 
FROM [CovidDeaths (1)]
WHERE Location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Shoes what percentage of population got Covid in the selected country
SELECT location, date, population, total_cases, (total_cases / population)*100 
FROM [CovidDeaths (1)]
WHERE Location LIKE '%states%'
and continent IS NOT NULL
ORDER BY 1, 2

--Looking at coutries with highest infection rate comapred to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount, 
MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM [CovidDeaths (1)]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest death count per population
SELECT Location, population, MAX(total_deaths) AS HighestDeathCount,
MAX((total_deaths / population))*100 AS PercentPopulationDeath
FROM [CovidDeaths (1)]
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationDeath DESC

SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM [CovidDeaths (1)]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Looking at continent with highest death count per population
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM [CovidDeaths (1)]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM [CovidDeaths (1)]
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Global Numbers
SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM [CovidDeaths (1)]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM [CovidDeaths (1)]
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at total population vs vaccinations using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM [CovidDeaths (1)] dea
JOIN [CovidVaccinations (1)] vac 
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopVacciPerPopu
FROM PopvsVac

--USING Temp Table
DROP TABLE IF EXISTS #PercentPopulationPopulated
CREATE TABLE #PercentPopulationPopulated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationPopulated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM [CovidDeaths (1)] dea 
JOIN [CovidVaccinations (1)] vac 
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopVacciPerPopu
FROM #PercentPopulationPopulated


--Creating view to store date for visualization later

CREATE VIEW PercentPopulationPopulated
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM [CovidDeaths (1)] dea 
JOIN [CovidVaccinations (1)] vac 
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationPopulated
