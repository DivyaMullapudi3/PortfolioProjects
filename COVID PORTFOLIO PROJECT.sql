
select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at Total Cases Vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2


-- looking at total cases vs pop

select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from CovidDeaths
where location like '%states%'
--where location like '%India%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, MAX(total_cases) AS highestinfectioncount, population, max((total_cases/population))*100 as percentpopinfected
from CovidDeaths
group by location, population
--where location like '%states%'
--where location like '%India%'
order by 2 desc

-- showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) AS maxdeaths
from CovidDeaths
where continent is not null
group by location
order by 2 desc

-- BY CONTINENT

select location, MAX(cast(total_deaths as int)) AS maxdeaths
from CovidDeaths
where continent is null
group by location
order by 2 desc

--- global numbers

select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) totaldeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- tot pop vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rollingcount
from CovidDeaths dea
join CovidVaccinations vac
   on dea.location =  vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

with PopVsVac (continent, location, date, population,new_vacc,rollingcount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rollingcount
from CovidDeaths dea
join CovidVaccinations vac
   on dea.location =  vac.location
   and dea.date = vac.date
where dea.continent is not null
--order 2,3
)
--select *
--from PopVsVac

select *, (rollingcount/population)*100
from PopVsVac
--order by 7 desc

--TEMP TABLE

DROP Table if exists #Percentpopvac
Create Table #Percentpopvac
( continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rollingcount numeric
 ) 

 insert into #Percentpopvac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rollingcount
from CovidDeaths dea
join CovidVaccinations vac
   on dea.location =  vac.location
   and dea.date = vac.date
--where dea.continent is not null

select *, (rollingcount/population)*100
from #Percentpopvac
order by 2,3

-- Creating view to store data for later visualizations

CREATE VIEW Percentpopvac AS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rollingcount
from CovidDeaths dea
join CovidVaccinations vac
   on dea.location =  vac.location
   and dea.date = vac.date
where dea.continent is not null

SELECT *
FROM Percentpopvac












