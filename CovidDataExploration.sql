/*

	Covid 19 Data Exploration 


*/


--SELECT Global Total Cases, Total Deaths, and Death Percentage 


SELECT
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS death_percentage
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent is not null 
ORDER BY
	1,2





--SELECT Global Total Cases, Total Deaths, and Death Percentage 
--COMPARE to previous query this time grouping by 'World' to find if they have similar results


SELECT
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS death_percentage
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	location = 'World'
ORDER BY 
	1,2





--SELECT US Total Cases, Total Deaths, and Death Percentage 


SELECT
	SUM(new_cases) AS us_total_cases,
	SUM(cast(new_deaths AS int)) AS us_total_deaths,
	SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS us_death_percentage
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	Location LIKE '%states%'
ORDER BY
	1,2




--SUMMARIZE Deathcount by Continent 


SELECT 
	location,
	SUM(cast(new_deaths AS int)) AS total_death_count
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent IS NULL 
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY
	location
ORDER BY
	total_death_count DESC




--SELECT Location, Population, Highest Infection Count and The Percent Population Infected


SELECT
	Location,
	Population,
	MAX(total_cases) AS highest_infection_count,
	Max((total_cases/population))*100 AS percent_population_infected
FROM
	PortfolioProject.dbo.CovidDeaths
GROUP BY 
	Location, 
	Population
ORDER BY 
	percent_population_infected DESC




--SELECT Location, Population, Highest Infection Count and The Percent Population Infected by date


SELECT
	Location,
	Population,
	date,
	MAX(total_cases) AS highest_infection_count,
	Max((total_cases/population))*100 AS percent_population_infected
FROM
	PortfolioProject.dbo.CovidDeaths
GROUP BY
	Location,
	Population,
	date
ORDER BY
	percent_population_infected DESC




--Calculate rolling percent population vaccinated 


WITH PopvsVacCountry (continent, location, date, population, new_vaccinations, rolling_ppl_vaccinated)
AS
(
	SELECT 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_ppl_vaccinated
	FROM 
		PortfolioProject.dbo.CovidDeaths AS dea
	JOIN
		PortfolioProject.dbo.CovidVaccinations AS vac
	ON
		dea.location = vac.location AND
		dea.date = vac.date
	WHERE 
		dea.continent IS NOT NULL
)

SELECT 
	*, (rolling_ppl_vaccinated/population)*100 AS rolling_vaccinated_percent
FROM 
	PopvsVacCountry





--Relationship between population density, human development index and death percentage


SELECT 
	dea.continent,
	dea.location,
	vac.population_density,
	vac.human_development_index,
	SUM(cast(dea.new_deaths AS int))/SUM(dea.New_Cases)*100 AS death_percentage
FROM 
	PortfolioProject.dbo.CovidVaccinations vac
JOIN 
	PortfolioProject.dbo.CovidDeaths dea
ON 
	vac.location = dea.location
	AND vac.iso_code = dea.iso_code
	AND vac.continent = dea.continent
	AND vac.date = dea.date
WHERE
	dea.continent IS NOT NULL
GROUP BY 
	dea.continent,
	dea.location,
	dea.population,
	vac.population_density,
	vac.human_development_index
ORDER BY 
	death_percentage 





--How fast did covid spread by population density


SELECT 
	dea.continent,
	dea.location,
	dea.date,
	vac.population_density,
	dea.new_cases,
	MAX(dea.total_cases) AS Rolling_Cases
FROM 
	PortfolioProject.dbo.CovidVaccinations vac
JOIN 
	PortfolioProject.dbo.CovidDeaths dea
ON 
	vac.location = dea.location
	AND vac.iso_code = dea.iso_code
	AND vac.continent = dea.continent
	AND vac.date = dea.date
WHERE
	dea.continent IS NOT NULL
GROUP BY 
	dea.continent,
	dea.location,
	dea.date,
	vac.population_density,
	dea.new_cases
ORDER BY 
	vac.population_density DESC





--How does the U.S. compare to the rest of the world in terms of preparedness


SELECT
	 AVG(hospital_beds_per_thousand) AS avg_hosp_beds_per_thousand,
	 AVG(handwashing_facilities) AS avg_handwashing_facilities
FROM 
	PortfolioProject.dbo.CovidVaccinations





SELECT
	AVG(hospital_beds_per_thousand) AS US_hosp_beds_per_thousand,
	AVG(handwashing_facilities) AS US_handwashing_facilities
FROM 
	PortfolioProject.dbo.CovidVaccinations
WHERE 
	Location LIKE '%states%'




