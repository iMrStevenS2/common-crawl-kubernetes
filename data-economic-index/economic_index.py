import pandas as pd

INPUT = "/data/terms_with_category.csv"
OUTPUT = "/data/textual_economic_index.csv"

df = pd.read_csv(INPUT)

# Filtrar solo términos económicos
filtered = df[df["category"] != "other"]

if filtered.empty:
    print("⚠️ No se encontraron términos económicos clasificados")
    filtered.to_csv(OUTPUT, index=False)
    exit(0)

index_df = (
    filtered
    .groupby("category")["final_score"]
    .sum()
    .reset_index()
    .sort_values("final_score", ascending=False)
)

index_df.to_csv(OUTPUT, index=False)
print("✔ Índice económico textual generado")
