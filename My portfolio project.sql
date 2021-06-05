
--Select Data that we are going to be using

select location, date, total_cases, new_cases , 
		total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths in India
-- To show the likelihood of dying if you contract covid in India
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as CasesvDeathsPercentage ,population
from PortfolioProject..CovidDeaths
where location like 'India' 
order by 1,2

--Looking at the total cases vs population in India

select location, date, total_cases, population ,
(total_cases/population)*100 as CasesvPopulationPercentage 
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to its population

select location, population , MAX(total_cases) as HighestInfectioncount,MAX((total_cases/population)*100) as CasesvPopulationPerCountry 
from PortfolioProject..CovidDeaths
group by location , population
order by CasesvPopulationPerCountry desc

--Countries with the highest death count according to their population
select Max(date) ,location, MAX(cast(total_deaths as int)) as TotalDeathscount,
MAX((total_deaths/population)*100) as DeathsvPopulationPerCountry 
from PortfolioProject..CovidDeaths
where continent is not null
group by location 
order by TotalDeathscount desc

--India infection rate compared to its population
select  Max(date), MAX(total_cases) as HighestInfectioncount,MAX((total_cases/population)*100) as CasesvPopulationPerCountry,
population
from PortfolioProject..CovidDeaths
where location like 'India'
group by  population
order by CasesvPopulationPerCountry 

--Now Lets see continents

-- showing continent with the highedt deathcount


select continent, MAX(cast(total_deaths as int)) as TotalDeathscount 
from PortfolioProject..CovidDeaths
where continent is not null -- and location not like 'world'
group by continent
order by TotalDeathscount desc

-- Global numbers

-- total deaths and cases everydat on global level

select date, sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like 'World'
where continent is not null
group by date
order by 1,2

--per million
select date, sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like 'World'
where  continent is not null 
group by date 
order by 1,2

--overall covid cases and deaths
select sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like 'World'
where  continent is not null 
--group by date
order by 1,2

--covid vaccination table
select  * 
from PortfolioProject..CovidVaccinations

-- total population vs vaccination

--Select death.continent, death.location , death.date, death.population, new_vaccinations,
--sum(cast(new_vaccinations as int)) over (partition by death.location) as vaccinations
----or sum(convert(int,new_vaccinations)) this will also do the work
--from PortfolioProject..CovidDeaths death
--join PortfolioProject..CovidVaccinations Vaccinations
--	on death.location = Vaccinations.location
--	and death.date = Vaccinations.date
--where death.continent is not null
--order by 2,1

--per country vaccinations on rolling count

Select death.continent, death.location , death.date, death.population, new_vaccinations,
sum(cast(new_vaccinations as int))--or sum(convert(int,new_vaccinations)) this will also do the work
over (partition by death.location order by death.location, death.date) as rollingpeoplevaccinations


from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations Vaccinations
	on death.location = Vaccinations.location
	and death.date = Vaccinations.date
where death.continent is not null
order by 2,1

--use cte
with populationVvaccination(continent , location, date, population , new_vaccination , rollingpeoplevaccinations)
as --if no.of inputs differ it will throw an an error like delagate input
(
Select death.continent, death.location , death.date, death.population, new_vaccinations,
sum(cast(new_vaccinations as int))--or sum(convert(int,new_vaccinations)) this will also do the work
over (partition by death.location order by death.location, death.date) as rollingpeoplevaccinations
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations Vaccinations
	on death.location = Vaccinations.location
	and death.date = Vaccinations.date
where death.continent is not null
--order by 2,1
)
select *, (rollingpeoplevaccinations/population)*100

from populationVvaccination
order by 2,1

-- try to get data of a country total population vaccinated vs totalpopulation

select location, max(date),population, max(new_vaccinations) as vaccinated,
max((new_vaccinations/population)*100) as vaccinated
from PortfolioProject..CovidVaccinations
where continent is not null
group by location,population
order by 1,2


--dropping the created table
drop table if exists percentpopulationvaccinated

--creating a temperory table on percent of people vaccinated 
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)
insert into #percentpopulationvaccinated
Select death.continent, death.location , death.date, death.population, new_vaccinations,
sum(cast(new_vaccinations as int))--or sum(convert(int,new_vaccinations)) this will also do the work
over (partition by death.location order by death.location, death.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations Vaccinations
	on death.location = Vaccinations.location
	and death.date = Vaccinations.date
--where death.continent is not null
--order by 2,1

select *, (rollingpeoplevaccinated/population)*100

from #percentpopulationvaccinated
order by 2,1

--Create a view 
--for data visulaization
create view percentpopulation as
Select death.continent, death.location , death.date, death.population, new_vaccinations,
sum(cast(new_vaccinations as int))--or sum(convert(int,new_vaccinations)) this will also do the work
over (partition by death.location order by death.location, death.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations Vaccinations
	on death.location = Vaccinations.location
	and death.date = Vaccinations.date
where death.continent is not null

select *
from percentpopulation
order by 2,1

