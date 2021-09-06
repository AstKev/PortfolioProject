
-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in Canada

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%Canada%'
order by 1,2;

-- looking at the total cases vs population
-- shows what percentage of population got Covid

select location, date,population, total_cases,  (total_cases/population)*100 as CasePercentage
from covid_deaths
where location like '%Canada%'
order by 1,2;

-- looking at countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths
--where location like '%Canada%'
GROUP BY location, population
order by 4 desc; 

-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from covid_deaths
where continent is not null
GROUP BY location

order by 2 desc; 

-- let's break things down by continent 

-- showing the continents with the highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from covid_deaths
where continent is not null
GROUP BY continent
order by 2 desc;

-- Global numbers

use covid; 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid_deaths
--where location like '%Canada%'
where continent is not null
--group by date
order by 1,2;


-- looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from covid_deaths dea
    join 	
	covid_vaccines  vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- use cte

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from covid_deaths dea
    join 	
	covid_vaccines  vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccination/population)*100
from PopvsVac;

-- Temp table



drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric, 
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 )

insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from covid_deaths dea
    join 	
	covid_vaccines  vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null;
--order by 2,3;

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from covid_deaths dea
    join 	
	covid_vaccines  vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3;

-- creating view for highest death count by continent
create view HighestDeathCountbyContinent as
select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from covid_deaths
where continent is not null
GROUP BY continent;
--order by 2 desc;

-- view for canada  total cases / total deaths
create view CanadaTotalCasesDeath as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%Canada%';
--order by 1,2;

-- view for canada total cases / population
create view CanadaTotalCasesPopulation as
select location, date,population, total_cases,  (total_cases/population)*100 as CasePercentage
from covid_deaths
where location like '%Canada%';
--order by 1,2;


