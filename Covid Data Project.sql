--Select *
--From CovidProject..CovidDeaths
--Order by 3,4

--Select *
--From CovidProject..CovidVaccinations
--Order by 3,4


--To see deaths per cases on by each day in the United States
--I took out total deaths that don't have values because create a baseline
Select Location, date, population, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as "deaths_per_cases"
From CovidProject..CovidDeaths
Where Location like '%States%' AND total_deaths IS NOT NULL
order by 1,2

--To see the total cases based on population size
Select 
	Location, date, population, total_cases, new_cases, total_deaths,
	(total_cases/population)*100 as "cases_by_population_percentage"
From CovidProject..CovidDeaths
Where Location like '%States%' AND total_deaths IS NOT NULL
order by 1,2

--To show the population of infected at each countries peak
-- and the percentage infected at the time
Select Location, Population, MAX(total_cases) as PeakPopulationInfected,
MAX((total_cases/Population))*100 as Percentage_Infected
From CovidProject..CovidDeaths
Where total_cases IS NOT NULL --I want to see the countries with cases
Group by Location, Population
Order by Percentage_Infected desc

--Looking at total population vaccinated
Select DT.continent, DT.location, DT.date, VT.new_vaccinations,
 SUM(Convert(int, VT.new_vaccinations)) OVER (Partition by DT.location Order by DT.location, DT.date) as Vaccinations_by_location
From CovidProject..CovidDeaths DT
Join CovidProject..CovidVaccinations VT
	On DT.location = VT.location
	and DT.date = VT.date
Where DT.continent IS NOT NULL
