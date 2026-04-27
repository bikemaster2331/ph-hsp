# Catanduanes Healthcare Access Gap Analysis

An analysis of healthcare gaps across the 11 municipalities of Catanduanes province, Philippines. The project builds a composite risk scoring model using hospital bed capacity, geographic access time, facility level, and mortality data.

---

## Project Overview

Republic Act 11223 (Universal Health Care Act) - A law that mandates no Filipino should be more than 30 minutes from a primary care facility.

Catanduanes is an island province in Bicol Region (Region V) with a total population of roughly 261,000 across 11 municipalities. The uneven distribution of hospitals means several municipalities depend on hospitals more than an hour away.

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

## Limitations

- Travel times are based off Google Maps and do not account for weather, road conditions, or time of day.
- Bed occupancy rates are not available for most hospitals. A hospital with 25 licensed beds running at 90% occupancy is functionally worse than the bed count implies. This model uses licensed beds as a proxy.
- The model assumes each municipality uses only its nearest hospital. In practice, patients with means bypass Level 1 facilities for Level 2 care in Virac, which concentrates pressure on EBMC and CDHI beyond what their assigned catchments suggest.