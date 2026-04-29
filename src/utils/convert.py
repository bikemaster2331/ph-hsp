import pandas as pd

xl = pd.ExcelFile('data/processed/result/table2.xlsx')
all_regions = []

for sheet_name in xl.sheet_names:
    df = pd.read_excel('data/processed/result/table2.xlsx', sheet_name=sheet_name, skiprows=4)
    df['region_name'] = sheet_name 
    all_regions.append(df)

master_df = pd.concat(all_regions, ignore_index=True)

# --- THE MISSING LINE ---
master_df.to_csv('data/processed/result/master_table2.xlsx', index=False)
# ------------------------

print("Success: master_table2.xlsx has been created in data/processed/result/")