import os
import glob
import pandas as pd

ANALYSIS_DIR = "/data/analysis"
OUTPUT_FILE = "/data/final_terms.csv"

# Obtener todos los archivos parciales generados por los workers
files = glob.glob(os.path.join(ANALYSIS_DIR, "partial_*.csv"))

if not files:
    print("⚠️ No se encontraron archivos parciales. Ejecuta los análisis primero.")
    exit(0)

dfs = []
for f in files:
    try:
        df = pd.read_csv(f, header=None, names=["term", "score"])
        # Convertir la columna score a numérico, reemplazando valores no numéricos por 0
        df["score"] = pd.to_numeric(df["score"], errors="coerce").fillna(0)
        dfs.append(df)
    except Exception as e:
        print(f"⚠️ Error leyendo {f}: {e}")
        continue

if not dfs:
    print("⚠️ No hay datos válidos para agregar.")
    pd.DataFrame().to_csv(OUTPUT_FILE)
    exit(0)

# Concatenar todos los datos parciales
final_df = pd.concat(dfs)

# Sumar los scores por término
final_df = final_df.groupby("term", as_index=False)["score"].sum()

# Normalizar
final_df["final_score"] = final_df["score"] / final_df["score"].sum()

# Ordenar de mayor a menor
final_df.sort_values("final_score", ascending=False, inplace=True)

# Guardar el CSV final
if os.path.exists(OUTPUT_FILE):
    os.remove(OUTPUT_FILE)

final_df.to_csv(OUTPUT_FILE, index=False)
print(f"✔ Aggregation completada. Archivo final: {OUTPUT_FILE}")

