Select *
From CovidDeaths$
where continent is not null
order by 3,4

Select *
From CovidVaccinations$
order by 3,4

--Select data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths 

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at total cases vs population
--Showing what percentage of population got Covid

Select location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from CovidDeaths$
where location like '%states'
order by 1,2

--looking at countries with highest infection rate compared to population 

Select location,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths$
--where location like '%states%'
Group By Location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population


Select location,MAX(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%states%'
Where continent is not null
Group By Location
order by totaldeathcount desc


Breaking data down by continent 
Select continent, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

--Global numbers

Select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2

Total cases, deaths, death percentage across the world
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Total population vs total vaccnations

Select *
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date)
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--OR

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

----CTE

With PopvsVac (Continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(55),
Location nvarchar(55),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3