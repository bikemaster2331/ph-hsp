-- The full investment table
SELECT * FROM v_investment_signal ORDER BY priority_rank;

-- The hospital catchment stress table
SELECT
    hospital,
    hospital_location,
    level,
    ownership,
    municipalities_served,
    serves,
    catchment_population,
    effective_beds,
    beds_per_1000,
    bed_surplus_deficit,
    worst_travel_min
FROM v_catchment_analysis
ORDER BY beds_per_1000 ASC;

