
Select *
From CovidPortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From CovidPortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Where continent is not null


--Looking at Total Cases vs Total Deaths
--Shows the likely hood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From CovidPortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at the total Cases vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 AS population_infected_percentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at countries with higest infection rate compared to population
Select location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 as 
covid_percentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order by covid_percentage desc

--Showing countries with highest death count per populatoin
Select location, MAX(cast(total_deaths AS int)) AS total_death_count
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order by total_death_count desc

--Let's break things down by continent
--Showing the continents with higest death counts
Select location, MAX(cast(total_deaths AS int)) AS total_death_count
From CovidPortfolioProject..CovidDeaths
Where continent is null
Group By location
Order by total_death_count desc


--Global numbers
Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast
	(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
Order by 1,2

--Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS
	rolling_people_vaccinated
	--, (rolling_people_vaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--use CTE
With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS
	rolling_people_vaccinated
	--, (rolling_people_vaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rolling_people_vaccinated/population)*100
From pop_vs_vac


--temp table

Drop Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccination numeric, 
rolling_people_vaccinated numeric
)

Insert Into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS
	rolling_people_vaccinated
	--, (rolling_people_vaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (rolling_people_vaccinated/population)*100
From #percent_population_vaccinated


--creating view to store data for later visualizations

CREATE VIEW percentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS
	rolling_people_vaccinated
	--, (rolling_people_vaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3