/*

	Covid 19 Data Exploration 

*/

-- Data Exploration in CovidDeaths Tables

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--- Global DeathRate

Select SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_deaths, SUM(CONVERT(int, new_deaths))/SUM(new_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where continent is not null

-- DeathRate in Canada

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where location like '%canada%'
And continent is not null
Order by 1,2

-- Highest InfectionRate in Countries

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by InfectionRate desc



-- Highest TotalDeathRate in Countries

Select location, MAX(CONVERT(int, total_deaths)) as TotalDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathRate desc


-- Highest TotalDeathRate by Continent

Select continent, MAX(CONVERT(int, total_deaths)) as TotalDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathRate desc


-- Data Exploration in CovidVaccination Tables

Select *
From PortfolioProject..CovidVaccination
Order By 3,4

-- Join both tables to shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations))  OVER (Partition by dea.Location Order by dea.location, dea.Date) as VaccinatedPeople

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, location, date, population, new_vaccinations, VaccinatedPeople)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as VaccinatedPeople

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 

)
Select *, (VaccinatedPeople/population)*100 as VaccinatedRate
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as VaccinatedPeople

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	And dea.date = vac.date

Select *, (VaccinatedPeople/population)*100 as VaccinatedRate
From #PercentPopulationVaccinated


-- Creating view for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as VaccinatedRate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 