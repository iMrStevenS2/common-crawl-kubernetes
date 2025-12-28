import pandas as pd
import re
import math

# --- Rutas ---
INPUT = "/data/final_terms.csv"
OUTPUT = "/data/final_terms_filtered.csv"

# --- Cargar ---
df = pd.read_csv(INPUT)

# --- Stopwords básicas ---
stopwords = set([
    # Español
    "la", "el", "los", "las", "de", "del", "en", "y", "o", "para", "con", "que", "se",
    # Inglés
    "the", "and", "for", "with", "to", "from", "of", "on", "by", "is", "are", "this",
    # Técnicas / ruido web
    "http", "https", "www", "html", "obj", "endobj"
])

# --- Normalizar ---
df["term"] = df["term"].astype(str).str.lower()

# --- Función anti-basura ---


def is_valid_term(term: str) -> bool:
    # solo letras latinas (evita cirílico, chino, etc.)
    if not re.fullmatch(r"[a-záéíóúñ]+", term):
        return False

    # longitud razonable
    if len(term) < 3 or len(term) > 30:
        return False

    # evita repeticiones tipo homehomehome
    for size in range(1, len(term)//2 + 1):
        if term == term[:size] * (len(term)//size):
            return False

    # evita baja entropía (lalalala, enenene)
    entropy = -sum(
        (term.count(c)/len(term)) * math.log2(term.count(c)/len(term))
        for c in set(term)
    )
    if entropy < 2.5:
        return False

    return True


# --- Aplicar filtros ---
df["term"] = df["term"].str.lower()

df = df[
    df["term"].apply(is_valid_term) &
    (~df["term"].isin(stopwords))
]


# --- Ordenar ---
df = df.sort_values("final_score", ascending=False)

# --- Guardar ---
df.to_csv(OUTPUT, index=False)

print(f"✔ Filtrado completado → {OUTPUT}")
print(f"✔ Términos finales: {len(df)}")
