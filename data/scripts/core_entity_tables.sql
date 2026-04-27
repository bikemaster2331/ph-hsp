CREATE TABLE municipalities (
    municipality_id     SERIAL PRIMARY KEY,
    name                VARCHAR(100) NOT NULL UNIQUE,
    province            VARCHAR(100) DEFAULT 'Catanduanes',
    region              VARCHAR(50)  DEFAULT 'Region V',
    population          INT NOT NULL,
    population_year     INT NOT NULL,
    area_km2            DECIMAL(8,2),
    is_capital          BOOLEAN DEFAULT FALSE
);

INSERT INTO municipalities (name, population, population_year, is_capital)
VALUES
    ('Virac',       75135, 2024, TRUE),
    ('San Andres',  37157, 2024, FALSE),
    ('Caramoran',   30124, 2024, FALSE),
    ('Viga',        21364, 2024, FALSE),
    ('Bato',        21325, 2024, FALSE),
    ('Pandan',      20796, 2024, FALSE),
    ('San Miguel',  14578, 2024, FALSE),
    ('Baras',       12992, 2024, FALSE),
    ('Bagamanoc',   10403, 2024, FALSE),
    ('Panganiban',   8947, 2024, FALSE),
    ('Gigmoto',      8348, 2024, FALSE);


CREATE TABLE hospitals (
    hospital_id           SERIAL PRIMARY KEY,
    name                  VARCHAR(150) NOT NULL,
    short_name            VARCHAR(60),
    municipality          VARCHAR(100) NOT NULL REFERENCES municipalities(name),
    ownership             VARCHAR(20) CHECK (ownership IN ('Government', 'Private')),
    level                 INT CHECK (level IN (1, 2, 3)),
    licensed_beds         INT NOT NULL,
    operational_beds      INT,
    occupancy_rate        DECIMAL(5,2),
    philhealth_accredited BOOLEAN,
    address               TEXT
);

INSERT INTO hospitals (name, short_name, municipality, ownership, level, licensed_beds, address)
VALUES
    ('Eastern Bicol Medical Center',
     'EBMC', 'Virac', 'Government', 2, 84,
     'San Isidro Village, Virac, Catanduanes'),

    ('Catanduanes Doctors Hospital, Inc.',
     'CDHI', 'Virac', 'Private', 2, 60,
     'Barangay Valencia, Virac, Catanduanes'),

    ('Immaculate Heart of Mary Hospital, Inc.',
     'IHMH', 'Virac', 'Private', 2, 36,
     'E. Rafael St., Rawis, Virac, Catanduanes'),

    ('Pandan District Hospital',
     'PDH', 'Pandan', 'Government', 1, 25,
     'Vera Street, Napo, Pandan, Catanduanes'),

    ('Juan M. Alberto Memorial District Hospital',
     'JMAM', 'San Andres', 'Government', 1, 25,
     'Belmonte, San Andres, Catanduanes'),

    ('Viga District Hospital',
     'VDH', 'Viga', 'Government', 1, 25,
     'San Vicente, Viga, Catanduanes');


CREATE TABLE hospital_access (
    access_id       SERIAL PRIMARY KEY,
    municipality    VARCHAR(100) NOT NULL REFERENCES municipalities(name),
    hospital_id     INT NOT NULL REFERENCES hospitals(hospital_id),
    travel_time_min INT NOT NULL,
    transport_type  VARCHAR(50) DEFAULT 'road',
    data_source     VARCHAR(100) DEFAULT 'field research'
);

INSERT INTO hospital_access (municipality, hospital_id, travel_time_min)
VALUES
    ('Caramoran',   5, 51),
    ('Bagamanoc',   6, 17),
    ('Panganiban',  6, 15),
    ('Gigmoto',     6, 78),
    ('Baras',       1, 64),
    ('Bato',        3, 21),
    ('San Miguel',  3, 32),
    ('Virac',       2, 15),
    ('Pandan',      4,  6),
    ('San Andres',  5, 15),
    ('Viga',        6, 17);


CREATE TABLE mortality_stats (
    stat_id               SERIAL PRIMARY KEY,
    municipality          VARCHAR(100) NOT NULL REFERENCES municipalities(name),
    year                  INT NOT NULL,
    total_deaths          INT,
    unknown_cause_count   INT,
    crude_death_rate      DECIMAL(6,2),
    infant_deaths         INT,
    fetal_deaths          INT,
    maternal_deaths       INT,
    UNIQUE (municipality, year)
);

INSERT INTO mortality_stats
    (municipality, year, total_deaths, crude_death_rate, infant_deaths, fetal_deaths, maternal_deaths)
VALUES
    ('Bagamanoc',  2024,  63,   NULL, 0,  0, 1),
    ('Baras',      2024,  93,   NULL, 0,  0, 0),
    ('Bato',       2024, 169,   NULL, 0,  1, 1),
    ('Caramoran',  2024, 164,   NULL, 0,  1, 1),
    ('Gigmoto',    2024,  59,   NULL, 0,  0, 0),
    ('Pandan',     2024, 161,   NULL, 0,  1, 0),
    ('Panganiban', 2024,  49,  18.81, 0,  0, 0),
    ('San Andres', 2024, 274,   1.27, 7,  1, 2),
    ('Viga',       2024, 131,   NULL, 0,  0, 0),
    ('Virac',      2024, 506,   NULL, 20, 20, 1),
    ('San Miguel', 2024, NULL,  NULL, 0,  0, 0);


CREATE TABLE province_cause_of_death (
    cod_id          SERIAL PRIMARY KEY,
    year            INT NOT NULL,
    cause_category  VARCHAR(100) NOT NULL,
    cause_detail    VARCHAR(150),
    death_count     INT NOT NULL,
    pct_of_total    DECIMAL(5,2),
    scope           VARCHAR(50) DEFAULT 'province'
);

INSERT INTO province_cause_of_death (year, cause_category, cause_detail, death_count, pct_of_total)
VALUES
    (2024, 'Cardiovascular', 'Hypertensive cardiovascular disease', 155,  8.70),
    (2024, 'Cardiovascular', 'Ischemic heart disease',               50,  2.80),
    (2024, 'Cardiovascular', 'Hypertension',                         28,  NULL),
    (2024, 'Cardiovascular', 'Coronary artery disease',              28,  NULL),
    (2024, 'External',       'Vehicular accident',                   24, 44.40),
    (2024, 'External',       'Suicide',                              16, 29.60),
    (2024, 'External',       'Accident (other)',                      8, 14.80),
    (2024, 'External',       'Drowning',                              4,  7.40),
    (2024, 'External',       'Fall',                                  2,  3.70),
    (2024, 'Unknown',        'No cause stated',                     502, 28.20);


CREATE VIEW v_catchment_analysis AS
SELECT
    h.hospital_id,
    h.short_name                                                        AS hospital,
    h.municipality                                                      AS hospital_location,
    h.ownership,
    h.level,
    h.licensed_beds,
    COALESCE(h.operational_beds, h.licensed_beds)                       AS effective_beds,
    h.occupancy_rate,
    COUNT(ha.municipality)                                              AS municipalities_served,
    STRING_AGG(ha.municipality, ', ' ORDER BY ha.municipality)         AS serves,
    SUM(m.population)                                                   AS catchment_population,
    MAX(ha.travel_time_min)                                             AS worst_travel_min,
    ROUND(AVG(ha.travel_time_min), 1)                                   AS avg_travel_min,
    ROUND(COALESCE(h.operational_beds, h.licensed_beds) * 1000.0
        / SUM(m.population), 4)                                         AS beds_per_1000,
    CEIL(SUM(m.population) / 1000.0)                                   AS who_required_beds,
    COALESCE(h.operational_beds, h.licensed_beds)
        - CEIL(SUM(m.population) / 1000.0)                             AS bed_surplus_deficit
FROM hospitals h
JOIN hospital_access ha ON h.hospital_id = ha.hospital_id
JOIN municipalities m   ON ha.municipality = m.name
GROUP BY
    h.hospital_id, h.short_name, h.municipality,
    h.ownership, h.level, h.licensed_beds,
    h.operational_beds, h.occupancy_rate;


CREATE VIEW v_municipality_gap AS
SELECT
    m.name                                              AS municipality,
    m.population,
    h.short_name                                        AS nearest_hospital,
    h.municipality                                      AS hospital_municipality,
    h.level                                             AS hospital_level,
    h.ownership,
    ha.travel_time_min,
    ca.beds_per_1000,
    ca.bed_surplus_deficit,
    ms.total_deaths,
    ms.crude_death_rate,
    ms.infant_deaths,
    ms.fetal_deaths,
    ms.maternal_deaths,

    ROUND((
        CASE
            WHEN ca.beds_per_1000 >= 2   THEN 0
            WHEN ca.beds_per_1000 >= 1   THEN 1
            WHEN ca.beds_per_1000 >= 0.5 THEN 2
            ELSE 3
        END
        +
        CASE
            WHEN ha.travel_time_min <= 15 THEN 0
            WHEN ha.travel_time_min <= 30 THEN 1
            WHEN ha.travel_time_min <= 60 THEN 2
            ELSE 3
        END
        +
        CASE
            WHEN h.level >= 2 THEN 0
            ELSE 2
        END
        +
        CASE
            WHEN ms.crude_death_rate IS NULL  THEN 1
            WHEN ms.crude_death_rate <= 7     THEN 0
            WHEN ms.crude_death_rate <= 12    THEN 1
            WHEN ms.crude_death_rate <= 18    THEN 2
            ELSE 3
        END
    ) * 100.0 / 11, 1)                                 AS risk_score_pct,

    CASE
        WHEN ha.travel_time_min > 60 AND ca.beds_per_1000 < 1
            THEN 'GREENFIELD'
        WHEN ha.travel_time_min > 60 AND ca.beds_per_1000 >= 1
            THEN 'TRANSPORT'
        WHEN ca.beds_per_1000 < 0.5 AND h.ownership = 'Government'
            THEN 'EXPANSION'
        WHEN h.level = 1 AND ca.beds_per_1000 < 1 AND h.ownership = 'Government'
            THEN 'UPGRADE'
        WHEN h.ownership = 'Private'
            THEN 'PRIVATE ENTRY'
        ELSE 'MONITOR'
    END                                                 AS intervention_type

FROM municipalities m
JOIN hospital_access ha     ON m.name = ha.municipality
JOIN hospitals h            ON ha.hospital_id = h.hospital_id
JOIN v_catchment_analysis ca ON h.hospital_id = ca.hospital_id
LEFT JOIN mortality_stats ms ON m.name = ms.municipality AND ms.year = 2024;


CREATE VIEW v_investment_signal AS
SELECT
    municipality,
    population,
    nearest_hospital,
    hospital_municipality,
    hospital_level,
    ownership,
    travel_time_min,
    ROUND(beds_per_1000, 2)             AS beds_per_1000,
    bed_surplus_deficit,
    crude_death_rate,
    risk_score_pct,
    intervention_type,
    RANK() OVER (ORDER BY risk_score_pct DESC) AS priority_rank,
    CASE
        WHEN intervention_type = 'GREENFIELD'
            THEN 'Buy land in ' || municipality || ' — new facility will be built here'
        WHEN intervention_type = 'EXPANSION'
            THEN 'Buy land in ' || hospital_municipality || ' near ' || nearest_hospital || ' — hospital grows outward'
        WHEN intervention_type = 'UPGRADE'
            THEN 'Buy land in ' || hospital_municipality || ' near ' || nearest_hospital || ' — upgrade attracts clinics and pharmacy'
        WHEN intervention_type = 'TRANSPORT'
            THEN 'No land play — road or ambulance problem, not hospital supply'
        WHEN intervention_type = 'PRIVATE ENTRY'
            THEN 'Buy commercial lot in ' || municipality || ' — population can support a private clinic'
        ELSE 'Watch and wait'
    END                                 AS land_play
FROM v_municipality_gap
ORDER BY priority_rank;


SELECT * FROM v_investment_signal;

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