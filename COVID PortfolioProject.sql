Select *
From PortfolioProject..CovidDeaths
Order by 3, 4


--  Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4
  
 Select Location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths

 ---Looking at total cases vs total deaths

  Select Location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as pecentageDeaths
 From PortfolioProject..CovidDeaths
 Where location like '%state%'
 Order by 1,2
  
 ---Looking at total cases vs populatuon 

  Select Location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as PecentpopulationInfect
  From PortfolioProject..CovidDeaths
 --Where location like '%state%'
 Order by 1,2

 ---Looking at Countries with Highest Infection Rate compared to Population


  Select Location, population, Max(total_cases) as HighestInfectionCount,population, Max(total_cases/population)*100 as PecentpopulationInfect
 From PortfolioProject..CovidDeaths
 --Where location like '%state%'
 Group by Location, population
 Order by PecentpopulationInfect DESC


 ---Showing Coutries with Highest DEATH Count per Population

  Select Location, Max(cast(total_deaths as int)) as totalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by Location 
 Order by totalDeathCount DESC

 --BREAKING DOWN BY CONTINENT

 --- showing CONTINENts with highest death

  Select continent, Max(cast(total_deaths as int)) as totalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by continent
 Order by totalDeathCount DESC


----Global NUMBER


sELECT  LOCATION, DATEADD(month, DATEDIFF(month, 0, Date), 0) as month, SUM(new_cases) sum_new_cases, SUM(CAST(new_deaths as int)) sum_new_deaths, 
SUM(CAST(new_deaths as int)) /NULLIF(SUM(new_cases),0)*100 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY DATEADD(month, DATEDIFF(month, 0, Date), 0), LOCATION
ORDER BY 1

--- B?ng COVID VACCINATIONS


------ Looking at Total Population vs Vaccinations



SELECT  Dea.location, Dea.continent, Dea. date, Dea.population, 
SUM(Convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location order by Dea.date, Dea.location) as Running_new_vaccinations
FROM PortfolioProject..CovidDeaths Dea	
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is not null
ORDER BY 1,2 


---USING CTE


WITH POPvsVac (Continent, Location, Date, Population, New_Vaccinations, Running_new_vaccinations)
as (
SELECT  Dea.location, Dea.continent, Dea. date, Dea.population, New_Vaccinations,
SUM(Convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location order by Dea.date, Dea.location) as Running_new_vaccinations
FROM PortfolioProject..CovidDeaths Dea	
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is not null
) 
SELECT *, Running_new_vaccinations/Population *100
FROM POPvsVac



---Temp table

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
Running_new_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
SELECT  Dea.location, Dea.continent, Dea. date, Dea.population, New_Vaccinations,
SUM(Convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location order by Dea.date, Dea.location) as Running_new_vaccinations
FROM PortfolioProject..CovidDeaths Dea	
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is not null

SELECT *, Running_new_vaccinations/Population *100
FROM #PercentPopulationVaccinated


---CREATING VIEW TO STORED DATA FOR LATER VISUALIZATIONS


CREATE VIEW PercentPopulationVaccinated AS
SELECT  Dea.location, Dea.continent, Dea. date, Dea.population, New_Vaccinations,
SUM(Convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location order by Dea.date, Dea.location) as Running_new_vaccinations
FROM PortfolioProject..CovidDeaths Dea	
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is not null