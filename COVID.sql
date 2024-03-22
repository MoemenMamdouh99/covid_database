
-- A quick look at the data 

SELECT* 
FROM [Covid data]..Covid_death
ORDER BY 3

SELECT*
FROM [Covid data]..Covid_vacc
ORDER BY 3


-- Exploring data 

-- looking at total cases vs. total deaths and find the death rate according to cases (in Egypt).

SELECT location , date ,total_cases,total_deaths, (CAST(total_deaths AS NUMERIC )/CAST(total_cases AS NUMERIC))*100 AS egy_death_rate
FROM Covid_death
WHERE location LIKE '%Egypt%'
ORDER BY egy_death_rate DESC


-- looking at total cases vs. population and shows the percentage of population got covid (in Egypt).

SELECT location , date ,population,total_cases, (CAST(total_cases AS NUMERIC)/population)*100 AS percent_popul
FROM Covid_death
WHERE location like '%Egypt%'
ORDER BY percent_popul DESC




-- looking at countries with highest infection rate compared to population.

SELECT location, date , MAX(CAST(total_cases AS INT)) AS highest_infec_count ,population,
MAX((CAST(total_cases AS INT)/population))*100 AS infection_rate
FROM Covid_death
GROUP BY location, date, population
ORDER BY infection_rate DESC 

-- showing countries with highest death count per population.

SELECT location, date , population , MAX(CAST(total_deaths AS INT )) AS highest_death_count ,
MAX((CAST(total_deaths AS INT )/population))*100 AS global_death_rate
FROM Covid_death
WHERE continent is not null  -- this to remove continent from location 
GROUP BY location , date , population
ORDER BY global_death_rate DESC


-- Joining the two tables 
-- looking at the percent of population that got vaccination


-- creating temp table
DROP TABLE IF EXISTS #perc_pop_vacc
CREATE TABLE #perc_pop_vacc
( location nvarchar(255),
  date  datetime,
  population numeric,
  new_vaccination numeric,
  Rolling_vacc_count numeric
  )
INSERT INTO #perc_pop_vacc
SELECT dea.location , dea.date ,dea.population ,vac.new_vaccinations as vaccination ,
sum(cast(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_vacc_count
FROM Covid_death AS dea 
JOIN Covid_vacc AS vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
ORDER BY Rolling_vacc_count 

-- calculating the percent of population that got vaccination
SELECT location , date , population, new_vaccination ,Rolling_vacc_count ,(Rolling_vacc_count/population)*100 AS percentage_population_vaccinated
FROM #perc_pop_vacc




 