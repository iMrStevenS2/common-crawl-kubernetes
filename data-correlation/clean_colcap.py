import pandas as pd

# Cargar CSV original de Investing
df = pd.read_csv(
    "/data/colcap_investing.csv",
    sep=",",
    quotechar='"'
)

# Renombrar columnas
df.columns = ["date", "close", "open", "high", "low", "volume", "pct_change"]

# Convertir fecha
df["date"] = pd.to_datetime(df["date"], format="%d.%m.%Y")

# Función para convertir números europeos


def parse_euro_number(x):
    if pd.isna(x):
        return None
    return float(
        x.replace(".", "").replace(",", ".")
    )


# Aplicar conversión
for col in ["close", "open", "high", "low"]:
    df[col] = df[col].apply(parse_euro_number)

# Ordenar por fecha
df = df.sort_values("date")

# Guardar versión limpia
df[["date", "close"]].to_csv(
    "/data/colcap_clean.csv",
    index=False
)
print("✔ COLCAP limpio generado en /data/colcap_clean.csv")
