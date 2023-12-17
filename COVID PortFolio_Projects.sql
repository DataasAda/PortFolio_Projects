select*
FROM PortfolioProject..CovidDeaths$
Where continent is not null
ORDER BY 3,4


--select*
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%Canada%'
ORDER BY 1,2

--looking at Total Cases VS Population
-- shows what percentage of Population got Covid
select location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Where location like '%Canada%'
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to Population

select location, population, Max(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%Canada%'
Group by location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Deaths counts per population

select location, max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%Canada%'
Where continent is not null
Group by location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK IT DOWN BY CONTINENT

select continent, max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%Canada%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount DESC

select location, max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%Canada%'
Where continent is null
Group by location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population

select continent, max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%Canada%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Canada%'
where continent is not null
group by date
ORDER BY 1,2


--  Total Population VS Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With popvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
From popvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated

create view ContinentTotalDeath AS
select continent, max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%Canada%'
Where continent is not null
Group by continent
--ORDER BY TotalDeathCount DESC