SELECT
    p.city_municipality ity_municipality,
    p.population,
    h.total_beds,
    (h.total_beds * 1000.0 / p.population) AS beds_per_1000
FROM catnes_population p
LEFT JOIN (
    SELECT municipality, SUM(CAST(beds AS INT)) AS total_beds
    FROM catnes_hospital
    GROUP BY municipality
) h
ON p.city_municipality = h.municipality;