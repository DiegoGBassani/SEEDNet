import pandas as pd

# Read the original CSV file
df = pd.read_csv('Data/Globe/dataset_cluster.csv')

# Select only the 'country' and 'year' columns
df_subset = df[['country', 'year']]

# Remove duplicates
df_unique = df_subset.drop_duplicates()

# Sort the data (optional)
df_sorted = df_unique.sort_values(['country', 'year'])

# Save to a new CSV file
df_sorted.to_csv('Data/Globe/extracted_list_of_countries.csv', index=False)