import pandas as pd
from financial_dictionary import FINANCIAL_TERMS

INPUT = "/data/final_terms_filtered.csv"
OUTPUT = "/data/terms_with_category.csv"

df = pd.read_csv(INPUT)
df["category"] = "other"

df["term"] = df["term"].astype(str).str.lower()

for category, words in FINANCIAL_TERMS.items():
    for w in words:
        df.loc[df["term"].str.contains(w, regex=False), "category"] = category

df.to_csv(OUTPUT, index=False)
print("✔ Clasificación completada")
