SELECT * 
FROM [dbo].[CovidDeaths]
ORDER BY 3,4

--SELECT * 
--FROM [dbo].[CovidVaccinations]
--ORDER BY 3,4

--DATA WE'RE GOING TO BE USING
SELECT Location,date, total_cases,new_cases,total_deaths,population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihod of dying if you contract covid in your country
SELECT Location,date, total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as '%dths/TotCases'
FROM [dbo].[CovidDeaths]
where location like '%rael%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentege of population has  got Covid
SELECT Location,date, total_cases,population,(total_cases/population)*100 as '%InfectedPopulation'
FROM [dbo].[CovidDeaths]
where location like '%rael%'
ORDER BY 1,2

--What Countries have the Highiest Infection Rate compared to Population ?
SELECT Location, population,max(total_cases) HighiestInfectionCount, max(total_cases/population)*100 as '%InfectedPopulation '
FROM [dbo].[CovidDeaths]
group by Location, population
ORDER BY 4 DESC

--Showing Countries with Highiest Death Count per Population
SELECT Location, max(cast(Total_deaths as int)) HighiestCoronaDeathCount, max(total_deaths/population)*100 as '%CoronaDeathsInPopulation '
FROM [dbo].[CovidDeaths]
where continent is not null
group by Location
ORDER BY 2 DESC

-- most corona deaths by country in continent
SELECT location,continent, max(cast(Total_deaths as int)) HighiestCoronaDeathCount, max(total_deaths/population)*100 as '%CoronaDeathsInPopulation '
FROM [dbo].[CovidDeaths]
where continent is not null
group by continent,location
ORDER BY 3 DESC

--most corona deaths by continent
SELECT continent, max(cast(Total_deaths as int)) HighiestCoronaDeathCount, max(total_deaths/population)*100 as '%CoronaDeathsInPopulation '
FROM [dbo].[CovidDeaths]
where continent is not null
group by continent
ORDER BY 2 DESC


--Global Numbers
Select date, SUM(new_cases) total_cases, SUM((cast(New_deaths as int))) as total_deaths,
(SUM((cast(New_deaths as int)))/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Cases in the World
Select  SUM(new_cases) total_Cases, SUM((cast(New_deaths as int))) as total_deaths,
((SUM((cast(New_deaths as int))))/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2


--Total population vs Vaccinations
Select de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CONVERT(Bigint,va.new_vaccinations)) over (partition by de.location order by de.location, de.date) RollingPeopleVaccinated
From CovidDeaths de 
Join CovidVaccinations va
on de.location=va.location and de.date=va.date
where de.continent is not null
order by 2,3

--CTE for Max Vaccinated

with PopVsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CONVERT(Bigint,va.new_vaccinations)) over (partition by de.location order by de.location, de.date) RollingPeopleVaccinated
From CovidDeaths de 
Join CovidVaccinations va 
on de.location=va.location and de.date=va.date
where de.continent is not null
--order by 2,3
)
--Max Vaccinated
select Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated, max(RollingPeopleVaccinated/population)*100 as '%VaccinatedVsPopulation'
from PopVsVac
group by Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated

