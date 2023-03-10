-- Total Cases vs Total Deaths
select Location, date, total_cases, total_deaths, (CAST(total_deaths as float) / CAST(total_cases as float))*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2  

-- Total Cases vs Population 
select Location, date, total_cases, population, (total_cases / population)*100 as infectedPercentage
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2 
 
 -- Highest infection rate for all countries
select Location, population, MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases / population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by Location, population
order by PercentPopulationInfected
desc


--Death Count by Location 
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by Location
order by TotalDeathCount
desc

--Death Count by Continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount
desc

--- Global Analysis 

--total numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
--order by 1,2

-- Vaccinations by Population
 -- Using CTE
With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVAccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location 
order by dea.location, dea.date)
as RollingPeopleVAccinated
from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select *, (RollingPeopleVAccinated/Population)*100 as per
from PopsVac



--TEMP TABLE 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations )) OVER (Partition by dea.Location 
order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea  
 join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null
--order by 2,3 
select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated



-- Storing temp table in a new view 
Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations )) OVER (Partition by dea.Location 
order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea  
 join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null  

select * 
from PercentagePopulationVaccinated