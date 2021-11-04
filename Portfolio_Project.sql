

Select * 
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

--Select Data that I will be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1,2


-- Looking at total case vs	total deaths
-- Shows likelihood of death when infected
Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2



-- Looking at the total cases vs population
-- Shows what percentage of population contracted covid
Select location, date, population, total_cases,(total_cases / population) * 100 as InfectionPercentage
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases / population)) * 100 as InfectionPercentage
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
Group by population, location
order by InfectionPercentage desc

--Showing Countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is  not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 ,(RollingPeopleVaccinated/dea.population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

With POPvsVAC (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100
from POPvsVAC

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View HighestDeathCountperPopulation as 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is  not null
Group by continent
--order by TotalDeathCount desc
