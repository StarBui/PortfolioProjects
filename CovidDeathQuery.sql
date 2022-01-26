-- Looking at total cases vs total deaths
-- shoes likelihood of dying if you contract covid 
SELECT Location, date, total_cases, total_deaths, round((cast(total_deaths as float)/cast(total_cases as float))*100,2) as DeathPercent
FROM [master].[dbo].[CovidDeaths]
where location like '%Australia%'
and continent is not NULL
order by 1,2

-- Looking at total cases vs population
--Shows percentage of population got covid
SELECT Location, date, Population total_cases, round((cast(total_cases as float)/cast(population as float))*100,2) as TotalCasesPercent
FROM [master].[dbo].[CovidDeaths]
where location like '%Australia%' and continent is not null
order by 1,2

-- Which Countries have the highest infection rate compared wto population?
SELECT Location, Population, MAX(total_cases) as HighestInfectioncount, max(round((cast(total_cases as float)/cast(population as float))*100,2)) as PercentPopulationInfected
FROM [master].[dbo].[CovidDeaths] 
where continent is not NULL
group by location, population
order by PercentPopulationInfected desc

-- Showing continents with highest death count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [master].[dbo].[CovidDeaths] 
where continent is NULL
group by location
order by TotalDeathCount desc


-- Countries with highest death count per population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM [master].[dbo].[CovidDeaths] 
where continent is not NULL
group by location
order by TotalDeathCount desc

-- Showing continents with highest death count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [master].[dbo].[CovidDeaths] 
where continent is NULL
group by location
order by TotalDeathCount desc

-- Global Numbers
SELECT date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, round(sum(cast(new_deaths as float)) / sum(cast(new_cases as float))*100,2) as DeathPercent
FROM [master].[dbo].[CovidDeaths]
where continent is not NULL
group by date
order by 1,2

-- Total Population Vs Population --USE CTE
with PopVsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as bigint)) OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM [master].[dbo].[CovidDeaths] cd
JOIN [master].[dbo].[CovidVaccinations] cv
ON cd.date = cv.date 
    and cd.location = cv.location
where cd.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- Temp Table
DROP table if EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
location NVARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as bigint)) OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM [master].[dbo].[CovidDeaths] cd
JOIN [master].[dbo].[CovidVaccinations] cv
ON cd.date = cv.date 
    and cd.location = cv.location
where cd.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Create view for data viz
create view PercentPopulationVaccinated as 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as bigint)) OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM [master].[dbo].[CovidDeaths] cd
JOIN [master].[dbo].[CovidVaccinations] cv
ON cd.date = cv.date 
    and cd.location = cv.location
where cd.continent is not null
