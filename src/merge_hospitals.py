import pandas as pd
import os
import numpy as np

def clean_dataframe(df, source_type):
    # 1. Drop completely empty columns
    df = df.dropna(axis=1, how='all')
    
    # 2. Drop noise columns ('#' or 'Unnamed')
    cols_to_drop = [col for col in df.columns if col.strip() == '#' or 'Unnamed' in col]
    df = df.drop(columns=cols_to_drop)
    
    # 3. Strip whitespace from column names BEFORE renaming
    df.columns = [col.strip() for col in df.columns]
    
    # 4. Standardize Column Naming (Fixed to match GPT's target schema)
    rename_dict = {
        'NAME OF FACILITY': 'hospital_name',
        'NAME OF HOSPITAL': 'hospital_name',
        'REGION': 'region',
        'PROVINCE': 'province',
        'CITY/ MUNICIPALITY': 'municipality',
        'OWNERSHIP': 'ownership',
        'OWNERSHIP CLASS': 'ownership_class',
        'CLASS': 'class',
        'SERVCE CAPABILITY': 'service_capability',
        'ABC': 'beds'
    }
    df = df.rename(columns=rename_dict)
    
    # Add source column
    df['source'] = source_type
    
    # 5. Normalize text data (strip whitespace, handle newlines, remove nan strings)
    for col in df.columns:
        if df[col].dtype == 'object':
            df[col] = df[col].fillna('').astype(str).str.replace('\n', ' ').str.strip()
            df[col] = df[col].replace('nan', '')
    
    # 6. Specific manual fixes
    if 'hospital_name' in df.columns and 'municipality' in df.columns:
        mask1 = (df['hospital_name'] == 'TIWI DOCTORS HOSPITAL') & (df['municipality'] == '')
        df.loc[mask1, 'municipality'] = 'Tiwi'
        
        mask2 = (df['hospital_name'].str.contains('TUBOD COMMUNITY HOSPITAL', na=False)) & (df['municipality'] == '')
        df.loc[mask2, 'municipality'] = 'Tubod'
            
    # 7. CRITICAL FIX: Convert beds to numeric so SQL can do math later
    if 'beds' in df.columns:
        # coerce turns bad strings into NaN, then fill NaN with 0, then cast to int
        df['beds'] = pd.to_numeric(df['beds'], errors='coerce').fillna(0).astype(int)

    return df

def main():
    raw_dir = 'data/raw'
    processed_dir = 'data/processed'
    os.makedirs(processed_dir, exist_ok=True)
    
    private_path = os.path.join(raw_dir, 'private_hosp.csv')
    govt_path = os.path.join(raw_dir, 'government_hosp.csv')
    
    print(f"Reading {private_path}...")
    df_private = pd.read_csv(private_path)
    df_private = clean_dataframe(df_private, 'Private')
    
    print(f"Reading {govt_path}...")
    df_govt = pd.read_csv(govt_path)
    df_govt = clean_dataframe(df_govt, 'Government')
    
    # Merge
    print("Merging dataframes...")
    merged_df = pd.concat([df_private, df_govt], ignore_index=True)
    
    # Drop duplicates based on the new standardized column names
    initial_len = len(merged_df)
    merged_df = merged_df.drop_duplicates(subset=['hospital_name', 'province', 'municipality'], keep='first')
    final_len = len(merged_df)
    
    if initial_len > final_len:
        print(f"Removed {initial_len - final_len} duplicate records.")

    # Reorder columns for database readiness
    priority_cols = ['hospital_name', 'source', 'region', 'province', 'municipality', 'ownership', 'ownership_class', 'class', 'service_capability', 'beds']
    
    # Keep any other columns that existed, just put them at the end
    other_cols = [c for c in merged_df.columns if c not in priority_cols]
    merged_df = merged_df[priority_cols + other_cols]
    
    output_path = os.path.join(processed_dir, 'merged_hospitals.csv')
    merged_df.to_csv(output_path, index=False)
    
    print(f"Success! Merged data saved to {output_path}")
    print(f"Final records: {len(merged_df)} (Original total: {initial_len})")

if __name__ == "__main__":
    main()