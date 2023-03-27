/* 
Exploring and Viewing DATA about Covid19
-- "CovidDeaths" "CovidVaccinations" is the names that I used for the Tables --
*/


--  Showing the data that I am going to be using

select location, date,population, total_cases, total_deaths
from dbo.CovidDeaths
where continent is not null 
And total_deaths is not null
order by 1,2

--  Shows percentage of dying if you contract covid in your country (I choose Egypt because that's where I live)

select location, date,population, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeath
from dbo.CovidDeaths
where continent is not null 
And total_deaths is not null
And location = 'Egypt'
order by 1,2

--  Shows what percentage of population got infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 As PercentageOFInfectedPeople
from dbo.CovidDeaths
where continent is not null 
order by 1,2

--  Shows the dates with the highest percentage of population that got infected with Covid

Select Date, location, population, total_cases, (total_cases/population)*100 As PercentageOFInfectedPeople
from dbo.CovidDeaths
where continent is not null 
And total_deaths is not null
order by PercentageOFInfectedPeople desc

--  Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) As HighestInfectionCount, MAX(total_cases/population)*100 As PercentPopulationInfected
from [#1 Project].dbo.CovidDeaths
Where population is not null
Group by location, population
Order by PercentPopulationInfected desc

--  Countries with Highest Death Percentage

select Location, Population, MAX(cast(total_deaths as int)) As TotalDeaths, MAX(cast(total_deaths as int)/population)*100 As PercentPopulationDied
from [#1 Project].dbo.CovidDeaths
Where population is not null
Group by location, population
Order by PercentPopulationDied desc

--  Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--  Showing contintents with the highest death count per population

select Location, MAX(cast(total_deaths As int)) As TotalDeaths
from dbo.CovidDeaths 
where continent is null 
Group By location, continent
order By TotalDeaths desc

--  World's Death Percentage

select SUM(new_cases) as TotalCases , SUM(cast(new_deaths As int)) As TotalDeaths , SUM(cast(new_deaths As int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

--  Shows Number of Population that has recieved at least one Covid Vaccine (Estimated by Date)

select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(convert (bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) as NumOfPeopleVacc 
from CovidDeaths dth
join CovidVaccinations vac 
on dth.location = vac.location 
And dth.date = vac.date
where dth.continent is not null 
And vac.new_vaccinations is not null 
order by 2,3

--	Shows Percentage of Population that has recieved at least one Covid Vaccine (Using CTE)

with VacPpl (continent, location, date, population, new_vaccinations, NumOfPeopleVacc)
As
(
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
 SUM(convert (bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) as NumOfPeopleVacc
from CovidDeaths dth
join CovidVaccinations vac 
on dth.location = vac.location 
And dth.date = vac.date
where dth.continent is not null 
And vac.new_vaccinations is not null 
)
Select* , (NumOfPeopleVacc/Population)*100
From VacPpl

--  Shows Percentage of Population that has recieved at least one Covid Vaccine (Using Temp Table)

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
NumOfPeopleVacc numeric
)
Insert into #PercentagePopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as NumOfPeopleVacc
From CovidDeaths dth
Join CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
Where dth.continent is not null 
And vac.new_vaccinations is not null
order by 2,3
Select *, (NumOfPeopleVacc/Population)*100 As Percentage
From #PercentagePopulationVaccinated

