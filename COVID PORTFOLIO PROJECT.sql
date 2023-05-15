select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--from PortfolioProject..[CovidVaccinations ]
--order by 3,4

--Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country


Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, Date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate comapared to Population

Select location, population, max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showig Countries with the Highest Death Count per Popoulation

Select location, max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS PER DAY

Select Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2 


--Looking at Total Population vs Vaccinations

Select dea.continent,dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RolligpPeopleVaccinated
From PortfolioProject..CovidVaccinations dea
Join PortfolioProject..CovidDeaths vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent,dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RolligpPeopleVaccinated
From PortfolioProject..CovidVaccinations dea
Join PortfolioProject..CovidDeaths vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric)


Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RolligpPeopleVaccinated
From PortfolioProject..CovidVaccinations dea
Join PortfolioProject..CovidDeaths vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creatin View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RolligpPeopleVaccinated
From PortfolioProject..CovidVaccinations dea
Join PortfolioProject..CovidDeaths vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated

