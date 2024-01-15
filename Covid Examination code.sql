--select *
--from PortfolioProjects..CovidDeaths
--order by 3, 4

--select *
--from PortfolioProjects..CovidVaccinations
--order by 3, 4

-- selecting data that we have to use
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
order by 1, 2

-- total death percentage
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like 'India'
order by 1, 2

-- total infected percentage
select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from PortfolioProjects..CovidDeaths
where location like 'India'
order by 1, 2

-- looking at the countries with highest infection rate compared to population
select top 15 location, Max(total_cases) as HighestInfectionCount, population, max((total_cases)/population)*100 as infectionRate
from PortfolioProjects..CovidDeaths
Group by location, population
order by 4 desc

-- showing the countries with highest death count per population
select location, population, sum(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- info by continent
select location, sum(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is null
group by location
order by 2 desc


-- highest death count of continents per population

select continent, sum(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- global data by date
select date, sum(cast(total_cases as int)) as totalCasesCount, sum(cast(total_deaths as int)) as totalDeathCount
, (sum(cast(total_deaths as float))/sum(cast(total_cases as float)))*100 as DeathRate
from PortfolioProjects..CovidDeaths
group by date
order by date



