WITH AggregatedData AS (
    SELECT
        SUM(Refugees_under_UNHCR_mandate) AS Total_Refugees,
        SUM(Stateless_persons) AS Total_Stateless_People,
        SUM(Asylum_seekers) AS Total_Asylum_Seekers,
        Year,
        Country_of_origin,
        Country_of_asylum
    FROM 
        un_data
    GROUP BY 
        Year, Country_of_origin, Country_of_asylum
),
-- Step 2: Rank top countries by total refugees originating and seeking asylum.
TopCountryOrigin AS (
    SELECT
        Year,
        Country_of_origin,
        Total_Refugees,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Total_Refugees DESC) AS `rank`
    FROM 
        AggregatedData
),
TopCountriesAsylum AS (
    SELECT
        Year,
        Country_of_asylum,
        SUM(Total_Refugees) AS Total_Asylum_Refugees,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY SUM(Total_Refugees) DESC) AS `rank`
    FROM 
        AggregatedData
    GROUP BY 
        Year, Country_of_asylum
)
SELECT
    o.Year,
    o.Country_of_origin AS Top_Country_Origin,
    o.Total_Refugees AS Top_Country_Refugees,
    a.Country_of_asylum AS Top_Country_Asylum,
    a.Total_Asylum_Refugees AS Top_Asylum_Refugees,
    a.`rank` AS Asylum_Rank
FROM 
    TopCountryOrigin o
LEFT JOIN 
    TopCountriesAsylum a
ON 
    o.Year = a.Year
WHERE 
    o.`rank` = 1 -- Top country of origin
    AND a.`rank` <= 3 -- Top 3 countries of asylum
ORDER BY 
    o.Year, a.`rank`;

