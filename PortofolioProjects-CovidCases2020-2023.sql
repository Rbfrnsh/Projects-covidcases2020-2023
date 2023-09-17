-- Portofolio Covid case 2020 - 2023
-- Robi Afriansyah

select *
from coviddeaths c
order by 3, 4

--select *
--from covidvaccination c 
--order by 3,4

-- Select Data that we are going to be using
select "location" , "date" , total_cases , total_deaths , population 
from coviddeaths c 
where continent is not null
order by 1,2

-- Total cases vs Total Death
-- shows likelihood of dying if you contract in your country
select "location" , "date" , total_cases , total_deaths ,(total_deaths::numeric/total_cases)*100 as Percentage 
from coviddeaths c 
where "location" like '%States%' and continent is not null
order by 1,2

-- Total Cases vs Population
-- shows percentage of population got covid
select "location" , "date" , population , total_cases ,(total_cases::numeric /population)*100 as Percentage 
from coviddeaths c 
--where "location" like '%States%'
where continent is not null
order by 1,2

-- the highest country with infection rate compared to population
select "location" , population  , max(total_cases)as HighestInfection, max(total_cases::numeric/population)*100 as Percentage 
from coviddeaths c 
--where "location" like '%States%'
where continent is not null
group by "location", population 
order by Percentage desc

-- country with Highest Death per Population
select "location" , max(cast(total_deaths as int))as HighestDeath 
from coviddeaths c 
-- where "location" like '%States%'
where continent is not null
group by "location" 
order by HighestDeath desc

-- break things down by continent


-- showing continents with the highest death count per population
select "location"  , max(cast(total_deaths as int)) as HighestDeath 
from coviddeaths c
where continent is null  
group by 1
order by HighestDeath desc


-- Global Numbers
select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as percentage 
from coviddeaths c
where continent is not null
--group by "date" 
order by 1,2


-- total populations vs vaccination
select c.continent, c."location", c."date", c.population, c2.new_vaccinations, SUM(cast(c2.new_vaccinations  as int)) over (partition by c."location" order by c."location", c."date") as RollingPeopleVaccinated
, (rollingpeoplevaccinated/population)* 100
From coviddeaths c
join covidvaccination c2 
	on c."location" = c2."location"
	and c."date" = c2."date" 
where c.continent is not null
order by 2,3


-- use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select c.continent, c."location", c."date", c.population, c2.new_vaccinations, SUM(cast(c2.new_vaccinations  as int)) over (partition by c."location" order by c."location", c."date") as RollingPeopleVaccinated
From coviddeaths c
join covidvaccination c2 
	on c."location" = c2."location"
	and c."date" = c2."date" 
where c.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated::numeric/population)*100
from PopvsVac

-- TEMP TABLE
drop table if exists PercentagePopulationVaccinated
create temporary table PercentagePopulationVaccinated
(
continent varchar(255),
location varchar(255),
date Timestamp,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentagePopulationVaccinated
select c.continent, c."location", c."date", c.population, c2.new_vaccinations, SUM(cast(c2.new_vaccinations  as int)) over (partition by c."location" order by c."location", c."date") as RollingPeopleVaccinated
From coviddeaths c
join covidvaccination c2 
	on c."location" = c2."location"
	and c."date" = c2."date" 
where c.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100 as PercentagePopVsVac
from PercentagePopulationVaccinated


-- Creating view to store data for late visualization
create view PercentPopulationVaccinated as 
select c.continent, c."location", c."date", c.population, c2.new_vaccinations, SUM(cast(c2.new_vaccinations  as int)) over (partition by c."location" order by c."location", c."date") as RollingPeopleVaccinated
From coviddeaths c
join covidvaccination c2 
	on c."location" = c2."location"
	and c."date" = c2."date" 
where c.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated p 