INSERT INTO catnes_hospital (
    hospital_name,
    region,
    province,
    municipality,
    ownership,
    service_capability,
    beds,
    "BLDG OR HOUSE NO., STREET, BRGY (as applicable)"
)
SELECT
    hospital_name,
    region,
    province,
    municipality,
    ownership,
    service_capability,
    beds,
    "BLDG OR HOUSE NO., STREET, BRGY (as applicable)"
FROM hospitals_raw
WHERE province = 'Catanduanes';