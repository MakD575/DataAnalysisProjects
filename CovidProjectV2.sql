select *
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--from CovidPortfolioProject..CovidVaccinations
--order by 3, 4

--Select Data for use

select location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


--Looking at Total Cases vs. Total Deaths

select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as PercentofPopulationInfected
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1, 2


--Looking at Total Cases vs. Population

select location, date, population, total_cases, (total_cases / population)*100 as PercentofPopulationInfected
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1, 2


--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases / population))*100 as PercentofPopulationInfected
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercentofPopulationInfected desc


--Showing Countries with Highest Death Count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--Showing Countries with Highest Death Count by Continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


--Showing Countries with Highest Death Count per Population

select location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths / population))*100 as PercentofPopulationDeceased
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercentofPopulationDeceased desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1, 2


--Total Population vs. Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingCountofPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingCountofPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingCountofPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingCountofPeopleVaccinated/population)*100
from PopvsVac


--Temp Table

--Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountofPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingCountofPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingCountofPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to Store Data for Visualization

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingCountofPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select *
from PercentPopulationVaccinated