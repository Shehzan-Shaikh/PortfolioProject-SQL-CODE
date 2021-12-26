--select * from PortfolioProject..covidVaccinations$
--OrDEr BY 3,4

select * from PortfolioProject..CovidDeath$
WHERE continent is not null
order by 3,4

--select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeath$
ORDER BY 1,2

--Looking at total_cases vs total_deaths
--Shows the likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percent 
FROM PortfolioProject..CovidDeath$
Where location Like '%states%'
ORDER BY 1,2

--Looking at the total_cases vs population
--shows what percentage of the population got covid
select Location,date,total_cases,population,(total_cases/population)*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeath$
--Where location Like 'India'
ORDER BY 1,2

--Countries with hightest infection rate compared to population
select Location,population,MAX(total_cases) as HightestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeath$
--Where location Like 'India'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with highest death count per population
Select Location,Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--WHERE location like 'India
WHERE continent is NOT NULL
GROUP BY location
Order By TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENTS

Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--WHERE location like 'India
WHERE continent is NOT NULL
GROUP BY continent
Order By TotalDeathCount DESC

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--WHERE location like 'India
WHERE continent is NULL
GROUP BY location
Order By TotalDeathCount DESC


--SHOWING THE CONTINENTS WITH HIGHEST DEATH COUNTS WITH PER POPULATION
Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--WHERE location like 'India
WHERE continent is NOT NULL
GROUP BY continent
Order By TotalDeathCount DESC


--Breaking GLobal NUmbers
select date,SUM(new_cases) AS total_cases,SUM(cast(new_deaths as INT)) as total_deaths,SUM(cast(new_deaths as INT))/SUM(NEW_cases)*100 AS DeathPercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percent 
FROM PortfolioProject..CovidDeath$
--Where location Like 'India'
WHERE continent is NOT NULL
GROUP BY  date
ORDER BY 1,2

--SHowing global Total

select SUM(new_cases) AS total_cases,SUM(cast(new_deaths as INT)) as total_deaths,SUM(cast(new_deaths as INT))/SUM(NEW_cases)*100 AS DeathPercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percent 
FROM PortfolioProject..CovidDeath$
--Where location Like 'India'
WHERE continent is NOT NULL
--GROUP BY  date
ORDER BY 1,2

--Looking at total_population vs total_vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..covidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE
WITh PopvsVac (continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..covidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)--order by clause cnnot be in CTE
SELECT *,(rollingpeoplevaccinated/population)*100 
FROM PopvsVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population Numeric,
New_vaccination Numeric,
RollingPeopleVaccinated Numeric
)
Insert INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..covidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
SELECT *,(rollingpeoplevaccinated/population)*100 
FROM #PercentPopulationVaccinated




--Creating VIEW to store Data for later data visualizations
--DROP VIEW if EXISTS PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..covidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3(No order By clause in View)

SELECT * FROM #PercentPopulationVaccinated