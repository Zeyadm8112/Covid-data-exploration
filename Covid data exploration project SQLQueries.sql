--SELECT * 


SELECT * 
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT  location,date,total_cases,new_cases,total_deaths,population
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total cases vs Total deaths

SELECT location,date,total_cases,total_deaths, (total_deaths / total_cases) * 100 AS death_precantage
FROM CovidAnalysis..CovidDeaths
WHERE location LIKE '%Egypt%' and continent is not null
ORDER BY 1,2 

-- Total cases vs population
SELECT location,date,population,total_cases,(total_cases/population) * 100  AS infection_percentage
FROM CovidAnalysis..CovidDeaths
WHERE location LIKE '%Egypt%' and  continent is not null
ORDER BY 1,2


--Highest infection rate

SELECT location,population,MAX(total_cases) AS highest_infection_count ,MAX((total_cases/population)) * 100 AS infection_percentage
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY infection_percentage DESC

--Highest death percentage by countries

SELECT location,MAX(CAST(total_deaths AS int)) as total_deaths_counts
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
GROUP By location
ORDER BY total_deaths_counts DESC


--Highest death percentage by continents

SELECT continent,MAX(CAST(total_deaths AS int)) as total_deaths_counts
FROM CovidAnalysis..CovidDeaths
WHERE continent is not  null
GROUP By continent
ORDER BY total_deaths_counts DESC

--GLobal deaths perct
SELECT SUM(new_cases) AS total_Cases,SUM(cast(new_deaths AS int)) AS total_Deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 AS global_Death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
ORDER By 1,2


--Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as rolling_people_vaccineted
FROM CovidAnalysis..CovidVaccinations vac
join CovidAnalysis..CovidDeaths dea
ON vac.location=dea.location and vac.date=dea.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE

WITH PopVsVac(Continent,location,date,population,new_vaccinations,rolling_people_vaccineted) AS

(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as rolling_people_vaccineted
FROM CovidAnalysis..CovidVaccinations vac
join CovidAnalysis..CovidDeaths dea
ON vac.location=dea.location and vac.date=dea.date
WHERE dea.continent is not null
)

SELECT *,(rolling_people_vaccineted/population) * 100 AS vaccineted_people_percentage
FROM PopVsVac



--temp table "anthor way"
DROP Table if exists #PercentPopulationVaccinated

CREATE TABLE  #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccineted numeric 

)
insert into #PercentPopulationVaccinated

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as rolling_people_vaccineted
FROM CovidAnalysis..CovidVaccinations vac
join CovidAnalysis..CovidDeaths dea
ON vac.location=dea.location and vac.date=dea.date
--WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (rolling_people_vaccineted/population) * 100 AS vaccineted_people_percentage
FROM #PercentPopulationVaccinated



-- Create View to store date for later visualizations

CREATE VIEW
PercentPopulationVaccinated as 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as rolling_people_vaccineted
FROM CovidAnalysis..CovidVaccinations vac
join CovidAnalysis..CovidDeaths dea
ON vac.location=dea.location and vac.date=dea.date
WHERE dea.continent is not null
--ORDER BY 2,3