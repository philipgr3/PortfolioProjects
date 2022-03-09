select * 
from PortfolioProject..CovidDeaths
order by 3, 4



select * 
from PortfolioProject..CovidVaccinations
order by 3, 4


-- Clear the table by choosing the columns that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

-- Some Global Stats

-- Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 


-- Total Cases vs Population 

select location, date, population, total_cases, (total_cases)/(population)*100 as Percentage_Infected
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

-- Countries with the Highest Infection Rate compared to Population

select location, population, max(total_cases) as highest_infection_count, (max(total_cases)/(population))*100 as Percentage_Infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Percentage_Infected desc

-- Countries with the Highest Death Count per Population

select location, max(cast(total_deaths as int)) as death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by death_count desc

-- Total Death Count per Continent

select location, max(cast(total_deaths as int)) as death_count
from PortfolioProject..CovidDeaths
where location not like '%income%' and continent is null
group by location
order by death_count desc

-- Total Covid Cases and Total Deaths

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths
from PortfolioProject..CovidDeaths
where continent is not null


-- Some stats for Greece 

-- Finding out on which day Greece had the most new cases

select location, date, population, new_cases, total_cases
from PortfolioProject..CovidDeaths
where location like '%greece' and  new_cases = (select max(new_cases) from PortfolioProject..CovidDeaths where location like '%greece')


-- Total Cases vs Total Deaths in Greece

select location, date, total_cases, total_deaths, (total_deaths)/(total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%greece'
order by 2 

-- Total Cases vs Population in Greece 

select location, date, population, total_cases, (total_cases/population)*100 as Percentage_Infected
from PortfolioProject..CovidDeaths
where location like '%greece'
order by 2 

-- Total Covid Cases and Total Deaths in Greece

select location, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from PortfolioProject..CovidDeaths
where location like '%greece'
group by location


-- Joinning the two tables to look at Total Vaccinations by summing the new vaccinations per country using partition by

select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) as total_vaccinations
from PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2, 3

-- Using Common Table Expression (CTE) to find what's the highest percentage of fully vaccinated people in Greece

With pplvaccgreece (Continent, Location, Date, Population, People_fully_vaccinated, Percentage_people_vaccinated)
as 
(select dth.continent, dth.location, dth.date, dth.population, vac.people_fully_vaccinated,
(people_fully_vaccinated/dth.Population)*100
from PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.location like '%greece'
)
select *
from pplvaccgreece
where percentage_people_vaccinated = (select max(percentage_people_vaccinated) from pplvaccgreece)


-- Doing the same thing using Temp Table clause

Drop table if exists #VaccPercentageGreece
Create Table #VaccPercentageGreece
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
People_fully_vaccinated numeric,
Percentage_people_vaccinated float
)
insert into #VaccPercentageGreece
select dth.continent, dth.location, dth.date, dth.population, vac.people_fully_vaccinated,
(vac.people_fully_vaccinated/dth.Population)*100
from PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.location like '%greece'
select *
from #VaccPercentageGreece
where percentage_people_vaccinated = (select max(percentage_people_vaccinated) from #VaccPercentageGreece)



