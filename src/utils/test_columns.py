import pandas as pd

# Load the file
hospitals = pd.read_excel('data/processed/population.xlsx')

# PRINT THE FIRST 5 ROWS AND THE COLUMNS
print("--- HEADERS ---")
print(hospitals.columns.tolist())
print("\n--- DATA PREVIEW ---")
print(hospitals.head(5))