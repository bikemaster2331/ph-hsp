# Catanduanes Healthcare Access Gap Analysis

A data-driven analysis of healthcare infrastructure gaps across the 11 municipalities of Catanduanes province, Philippines. The project builds a composite risk scoring model using hospital bed capacity, geographic access time, facility level, and mortality data — then translates those gaps into an investment signal for land and real estate positioning ahead of government health infrastructure spending.

---

## Background

Catanduanes is an island province in Bicol Region (Region V) with a total population of roughly 261,000 across 11 municipalities. It has six hospitals — three in the capital Virac, and one each in San Andres, Pandan, and Viga. This uneven distribution means several municipalities depend on hospitals more than an hour away, with some served only by Level 1 facilities incapable of handling cardiac emergencies or surgical cases.

The Republic Act 11223 (Universal Health Care Act) mandates that no Filipino should be more than 30 minutes from a primary care facility. Several municipalities in Catanduanes are in clear violation of this standard. This project quantifies that gap, ranks municipalities by urgency, and identifies the most probable sites for future government health infrastructure intervention.

---

## What This Project Does

1. **Builds a relational database** of hospitals, municipalities, population, access times, and mortality statistics
2. **Calculates catchment population per hospital** — not just beds in a municipality, but beds serving all municipalities that depend on that hospital
3. **Scores each municipality** on a composite risk index across four dimensions: bed supply, travel time, facility capability, and death rate pressure
4. **Classifies intervention type** — whether the most likely government response is a new facility (GREENFIELD), hospital expansion (EXPANSION), level upgrade (UPGRADE), or transport infrastructure (TRANSPORT)
5. **Outputs an investment signal table** that names the specific location and type of land play for each municipality

---

## Folder Structure

```
catanduanes-health-gap/
│
├── data/
│   ├── raw/                        # Original source files, never modified
│   │   ├── government_hosp.csv     # DOH licensed government hospitals
│   │   ├── private_hosp.csv        # DOH licensed private hospitals
│   │   └── population_raw.csv      # PSA 2020 census population by municipality
│   │
│   ├── processed/                  # Cleaned and merged outputs ready for import
│   │   ├── catnes_hospital.csv     # Final hospital table (merged gov + private)
│   │   ├── catnes_population.csv   # Final population table
│   │   └── hospitals_raw.csv       # Intermediate pre-merge hospital file
│   │
│   └── scripts/                    # Ordered SQL scripts for database setup
│       ├── 1_create_hospitals_raw.sql
│       ├── 2_create_catnes_population.sql
│       ├── 3_insert_catnes_population.sql
│       ├── 4_create_catnes_hospital.sql
│       ├── 5_insert_catnes_hospital.sql
│       └── 6_beds_per_1000.sql
│
├── notebooks/                      # Jupyter notebooks for EDA and visualization
│
├── notes/                          # Research notes, assumptions, source links
│
├── schema/
│   └── catanduanes_health.sql      # Full schema: tables, views, queries
│
├── src/
│   ├── merge_hospitals.py          # Merges government and private hospital CSVs
│   └── utils/                      # Shared helper functions
│
├── .gitignore
├── README.md
└── requirements.txt
```

> **Note:** The `hsp/` Python virtual environment folder is excluded from version control via `.gitignore`. Other contributors should create their own environment using `requirements.txt`.

---

## Database Schema

Five tables, three views.

### Tables

| Table | Description |
|---|---|
| `municipalities` | 11 municipalities with population and census year |
| `hospitals` | 6 licensed hospitals with level, ownership, and bed counts |
| `hospital_access` | Bridge table — which hospital each municipality depends on, and travel time in minutes |
| `mortality_stats` | Per-municipality death counts, crude death rate, and breakdown by infant/fetal/maternal for 2024 |
| `province_cause_of_death` | Province-level cause of death breakdown from PSA (cardiovascular, external, unknown) |

### Views

| View | Description |
|---|---|
| `v_catchment_analysis` | Per hospital: total catchment population, effective beds, beds per 1,000, worst travel time, surplus or deficit |
| `v_municipality_gap` | Per municipality: access metrics, risk score, and intervention classification |
| `v_investment_signal` | Final output: priority rank, intervention type, and specific land play recommendation |

---

## Risk Score Methodology

Each municipality is scored across four components. Higher score = worse access = higher intervention urgency.

| Component | Scoring | Max |
|---|---|---|
| Beds per 1,000 (catchment) | ≥2 → 0, ≥1 → 1, ≥0.5 → 2, below → 3 | 3 |
| Travel time to nearest hospital | ≤15 min → 0, ≤30 → 1, ≤60 → 2, above → 3 | 3 |
| Hospital level | Level 2+ → 0, Level 1 → 2 | 2 |
| Crude death rate (vs national ~6.5/1,000) | ≤7 → 0, ≤12 → 1, ≤18 → 2, above → 3, unknown → 1 | 3 |

**Formula:** `(sum of components / 11) × 100`

Max raw score is 11. Ownership is deliberately excluded from the risk score — it is not a measure of access deprivation. It is used only in the intervention type classification.

---

## Intervention Classification Logic

| Type | Condition | Land Play |
|---|---|---|
| `GREENFIELD` | Travel > 60 min AND beds/1,000 < 1 | Buy in the underserved municipality — facility comes to them |
| `EXPANSION` | Beds/1,000 < 0.5 AND government-owned | Buy near the existing hospital — it grows outward |
| `UPGRADE` | Level 1, beds/1,000 < 1, government-owned | Buy near the existing hospital — upgrade attracts clinics and pharmacy |
| `TRANSPORT` | Travel > 60 min but beds/1,000 ≥ 1 | No land play — supply is adequate, access is a road problem |
| `PRIVATE ENTRY` | Private hospital with gap | Buy commercial lot in the municipality |
| `MONITOR` | No critical threshold breached | Watch and wait |

---

## Key Findings

**Juan M. Alberto Memorial (San Andres)** serves the largest catchment of any Level 1 hospital in the province — 67,281 people across Caramoran and San Andres — with only 25 beds. That is 0.37 beds per 1,000, the lowest ratio in Catanduanes. It is government-owned and eligible for DOH expansion funding. The strongest candidate for a hospital expansion land play, located in San Andres.

**Viga District Hospital** serves four municipalities (Bagamanoc, Panganiban, Gigmoto, Viga) — a catchment of 49,062 — with 25 beds. Gigmoto is 78 minutes away. Panganiban has a crude death rate of 18.81 per 1,000, nearly three times the national average, while depending on this same overloaded Level 1 facility. The hospital itself is in Viga, where expansion land plays are concentrated.

**Gigmoto** is the GREENFIELD candidate. At 78 minutes from the nearest hospital with a catchment beds ratio of 0.51, it is in direct violation of RA 11223 geographic access standards. The most common DOH response to this scenario is a new rural health unit or district hospital within the municipality itself.

**28.2% of Catanduanes deaths in 2024 had no recorded cause of death** — a proxy indicator for out-of-hospital mortality. 261 deaths were cardiovascular, requiring at minimum a Level 2 facility. Multiple municipalities are served exclusively by Level 1 hospitals incapable of treating these cases.

---

## Data Sources

| Source | Data |
|---|---|
| Department of Health (DOH) | Hospital licensing data: name, level, ownership, licensed beds, address |
| Philippine Statistics Authority (PSA) | 2020 census population by municipality |
| PSA Catanduanes Provincial Statistical Office | 2024 mortality report: deaths by municipality, crude death rate, cause of death breakdown |
| Field research | Travel time estimates from each municipality to its nearest hospital |

Population figures used are from the 2020 census. Hospital data reflects DOH licensing records current as of 2025. Mortality data is from the 2024 PSA preliminary report.

---

## Setup

**Requirements:** Python 3.10+, PostgreSQL 14+

```bash
git clone https://github.com/yourusername/catanduanes-health-gap.git
cd catanduanes-health-gap

python -m venv hsp
source hsp/bin/activate          # Windows: hsp\Scripts\activate
pip install -r requirements.txt
```

**Database setup:**

```bash
psql -U postgres -c "CREATE DATABASE catanduanes_health;"
psql -U postgres -d catanduanes_health -f schema/catanduanes_health.sql
```

**Run the merge script** (combines government and private hospital CSVs):

```bash
python src/merge_hospitals.py
```

**Query the results:**

```sql
SELECT * FROM v_investment_signal;

SELECT * FROM v_catchment_analysis ORDER BY beds_per_1000 ASC;
```

---

## .gitignore

Ensure your `.gitignore` includes at minimum:

```
hsp/
__pycache__/
*.pyc
.env
.DS_Store
*.egg-info/
dist/
.ipynb_checkpoints/
```

---

## Limitations

- Population figures are from the 2020 census. Actual 2024–2025 populations will differ.
- Travel times are field-researched estimates and do not account for weather, road conditions, or time of day. Catanduanes is a typhoon-prone island where road access can be severely disrupted.
- Bed occupancy rates are not available for most hospitals. A hospital with 25 licensed beds running at 90% occupancy is functionally worse than the bed count implies. This model uses licensed beds as a proxy.
- The model assumes each municipality uses only its nearest hospital. In practice, patients with means bypass Level 1 facilities for Level 2 care in Virac, which concentrates pressure on EBMC and CDHI beyond what their assigned catchments suggest.
- Cause of death data is available only at the province level, not per municipality.