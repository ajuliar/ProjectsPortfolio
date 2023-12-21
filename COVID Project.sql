SELECT * FROM [dbo].[CovidDeaths]
Where continent is not null
ORDER by 3,4;

-- SELECT * FROM [dbo].[CovidVaccinations]
-- ORDER by 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
From [dbo].[CovidDeaths]
Where continent is not null
Order by 1,2;

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracted Covid in your country between the years 2020-2021 

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL) / total_cases)* 100 AS DeathPercentage
From [dbo].[CovidDeaths]
Where Location Like '%brazil%'
and continent is not null
Order by 1,2;

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (CAST(total_cases AS DECIMAL) / population)* 100 AS PercentPopulationInfected
From [dbo].[CovidDeaths]
Where continent is not null
-- Where Location Like '%brazil%'
Order by 1,2;

-- Looking at countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, (CAST(MAX(total_cases) AS DECIMAL) / population) * 100 AS PercentPopulationInfected
From [dbo].[CovidDeaths]
Where continent is not null
-- Where Location Like '%brazil%'
Group by location, population
Order by PercentPopulationInfected desc;

-- Showing Countries with the Highest Death Count per Population

SELECT Location, Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is not null
-- Where Location Like '%brazil%'
Group by location
Order by TotalDeathCount desc;

-- Now let's break down by continent
-- Showing Continents with the highest death count per population

SELECT continent, Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is not null
-- Where Location Like '%brazil%'
Group by continent
Order by TotalDeathCount desc;


-- Global Numbers

SELECT  Sum(new_cases) as total_cases, 
SUM(new_deaths) as total_deaths, 
CAST(SUM(new_deaths) AS DECIMAL) / SUM(new_cases) * 100 as DeathPercentage 
From [dbo].[CovidDeaths]
-- Where Location Like '%states%'
Where continent is not null
-- Group by date
Order by 1,2;


SELECT Sum(new_cases) as total_cases, 
SUM(new_deaths) as total_deaths, 
CAST(SUM(new_deaths) AS DECIMAL) / SUM(new_cases) * 100 as DeathPercentage 
From [dbo].[CovidDeaths]
Where continent is not null
Order by 1,2;


-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
CAST(SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS INT)
AS RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not NULL
order by 2,3;



--
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
CAST(SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS INT)
AS RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not NULL
)
SELECT *, CAST(RollingPeopleVaccinated as Decimal) /Population*100
FROM PopvsVac


--TEMP Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
CAST(SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS INT)
AS RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
    On dea.location = vac.location
    and dea.date = vac.date
-- where dea.continent is not NULL

SELECT *, CAST(RollingPeopleVaccinated as Decimal) /Population*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
CAST(SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS INT)
AS RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not NULL;


SELECT *
FROM PercentPopulationVaccinated;