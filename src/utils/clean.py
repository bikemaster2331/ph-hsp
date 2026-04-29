import pandas as pd

hospitals = pd.read_excel('data/processed/hospitals_raw.csv')
population = pd.read_excel('data/processed/population.xlsx')

# Standardize both: uppercase, strip whitespace
hospitals['CITY_MUNICIPALITY_CLEAN'] = hospitals['CITY/ MUNICIPALITY'].str.upper().str.strip()
population['CITY_MUNICIPALITY_CLEAN'] = population['city_municipality_col'].str.upper().str.strip()

# Attempt the join
merged = hospitals.merge(
    population,
    left_on=['PROVINCE', 'CITY_MUNICIPALITY_CLEAN'],
    right_on=['province_col', 'CITY_MUNICIPALITY_CLEAN'],
    how='left',
    indicator=True
)

# See what didn't match
unmatched = merged[merged['_merge'] == 'left_only'][['PROVINCE', 'CITY/ MUNICIPALITY']].drop_duplicates()
print(f"Unmatched: {len(unmatched)}")
print(unmatched.head(30))