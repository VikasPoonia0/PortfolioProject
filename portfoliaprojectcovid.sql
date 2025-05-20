select * 
from coviddeaths
order by 3,4;


select *
from covidvaccinations
order by 3,4;

-- select the data that we are going to use;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like 'India'
order by 1,2;


-- looking at total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected
from coviddeaths
-- where location like 'India'
order by 1,2;

-- looking at countries with highest infection rate vs population

select location, max(total_cases) as highest_infection_count, population, (max(total_cases)/population)*100 as percent_population_infected
from coviddeaths
-- where location like 'India'
group by location, population
order by percent_population_infected desc;


-- showing countries with highest death count vs population
select location, max(total_deaths) as total_death_count
from coviddeaths
where continent is not null
group by location
order by total_death_count desc;


-- breaking it by continent wise
-- location contains continent and continent column for this is empty so using this way
select location, max(total_deaths) as total_death_count
from coviddeaths
where continent is null
group by location
order by total_death_count desc;


-- global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
order by 1,2; 



-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac on dea.location=vac.location  and dea.date=vac.date
where dea.continent is not null
order by 2,3;



-- creating a table for percent of population vaccinated 
drop table if exists percentPopulationVaccinated;  
create table percentPopulationVaccinated  
(
continent nvarchar(255), location nvarchar(255), Date datetime, population bigint,
new_vaccinations bigint, RollingPeopleVaccinated double 
);
insert into percentPopulationVaccinated
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac on dea.location=vac.location  and dea.date=vac.date
where dea.continent is not null
order by 2,3;

select *, (RollingPeopleVaccinated/population)*100
from percentPopulationVaccinated;


-- creating view to store data for later visualizations
create view percentPopulationVaccinatedforView as
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac on dea.location=vac.location  and dea.date=vac.date
where dea.continent is not null
order by 2,3;
