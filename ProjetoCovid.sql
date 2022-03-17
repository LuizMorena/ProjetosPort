SELECT * FROM ProjetoCovid..CovidDeaths
where continent is not null
order by 3,4

--SELECT * FROM ProjetoCovid..CovidVaccinations
--order by 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM ProjetoCovid..CovidDeaths
where continent is not null
order by 1,2

-- Comparando Total de Casos vs Total de Mortes
-- Mostra a probabilidade de morrer ao contrair Covid no Brasil

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjetoCovid..CovidDeaths
Where location like '%brazil%'
and continent is not null
order by 1,2

-- Comparando o total de casos vs popula��o
-- Mostra a % da popula��o que pegou Covid

SELECT location,date, population, total_cases, (total_cases/population)*100 as InfectedRatio
FROM ProjetoCovid..CovidDeaths
Where location like '%brazil%'
and continent is not null
order by 1,2

-- Pa�ses com mais alta taxa de cont�gio de acordo com popula��o

SELECT location, population, MAX(total_cases) as HihgestInfectionCount, MAX((total_cases/population))*100 as InfectedRatio
FROM ProjetoCovid..CovidDeaths
--Where location like '%brazil%'
GROUP BY location, population
order by InfectedRatio desc

-- Pa�ses com a maior taxa de mortalidade

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjetoCovid..CovidDeaths
--Where location like '%brazil%'
where continent is not null
GROUP BY location, population
order by TotalDeathCount desc

-- Agrupando por continente

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjetoCovid..CovidDeaths
--Where location like '%brazil%'
where continent is not null
GROUP BY continent 
order by TotalDeathCount desc


-- Mostrando os continentes com mais mortes por habitante

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjetoCovid..CovidDeaths
--Where location like '%brazil%'
where continent is not null
GROUP BY continent 
order by TotalDeathCount desc

-- N�MEROS GLOBAIS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as
 DeathPercentage
FROM ProjetoCovid..CovidDeaths
Where continent is not null
--GROUP BY date
order by 1,2

-- Analisando a popula��o total vs Vacina��es

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM ProjetoCovid..CovidDeaths dea
JOIN ProjetoCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null)
--ORDER BY 2, 3)
	
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- TABELA TEMPOR�RIA

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM ProjetoCovid..CovidDeaths dea
JOIN ProjetoCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Criando uma View para armazenamento de dados para visualiza��o posterior

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM ProjetoCovid..CovidDeaths dea
JOIN ProjetoCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated

-- N�MEROS GLOBAIS VIEW

CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as
 DeathPercentage
FROM ProjetoCovid..CovidDeaths
Where continent is not null
--GROUP BY date
--order by 1,2


-- Mostrando os continentes com mais mortes por habitante VIEW

CREATE VIEW HighestDeathCont AS
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjetoCovid..CovidDeaths
--Where location like '%brazil%'
where continent is not null
GROUP BY continent 
--order by TotalDeathCount desc


-- Pa�ses com a maior taxa de mortalidade VIEW


CREATE VIEW CountriesDeathRate AS
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjetoCovid..CovidDeaths
--Where location like '%brazil%'
where continent is not null
GROUP BY location, population
--order by TotalDeathCount desc

-- Pa�ses com mais alta taxa de cont�gio de acordo com popula��o VIEW

CREATE VIEW HighestInfectionRate AS
SELECT location, population, MAX(total_cases) as HihgestInfectionCount, MAX((total_cases/population))*100 as InfectedRatio
FROM ProjetoCovid..CovidDeaths
--Where location like '%brazil%'
GROUP BY location, population
--order by InfectedRatio desc


-- Mostra a % da popula��o que pegou Covid VIEW

CREATE VIEW BRInfectionRate AS
SELECT location,date, population, total_cases, (total_cases/population)*100 as InfectedRatio
FROM ProjetoCovid..CovidDeaths
Where location like '%brazil%'
and continent is not null
--order by 1,2

-- Comparando Total de Casos vs Total de Mortes VIEW
-- Mostra a probabilidade de morrer ao contrair Covid no Brasil

CREATE VIEW BRDeathRate AS
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjetoCovid..CovidDeaths
Where location like '%brazil%'
and continent is not null
--order by 1,2