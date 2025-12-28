import os
import glob
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
import re

INPUT_DIR = "/data/clean"
OUTPUT_DIR = "/data/analysis"

WORKER_ID = int(os.getenv("WORKER_ID", 0))
TOTAL_WORKERS = int(os.getenv("TOTAL_WORKERS", 1))

os.makedirs(OUTPUT_DIR, exist_ok=True)

files = sorted(glob.glob(f"{INPUT_DIR}/*.txt"))
files = files[WORKER_ID::TOTAL_WORKERS]

vectorizer = TfidfVectorizer(
    stop_words="english",
    max_features=3000,
    min_df=3,
    max_df=0.85,
    token_pattern=r"(?u)\b[A-Za-z]{3,20}\b"  # solo palabras de 3-20 letras
)

df_acc = None
fitted = False

for f in files:
    docs = []
    with open(f, "r", encoding="utf-8", errors="ignore") as fh:
        for line in fh:
            line = re.sub(r"[^a-zA-Z\s]", " ", line.lower())
            if line.strip():
                docs.append(line.strip())

            if len(docs) >= 500:  # 🔥 límite RAM
                if not fitted:
                    X = vectorizer.fit_transform(docs)
                    fitted = True
                else:
                    X = vectorizer.transform(docs)

                terms = vectorizer.get_feature_names_out()
                scores = X.sum(axis=0).A1
                chunk_df = pd.DataFrame({"term": terms, "score": scores})

                if df_acc is None:
                    df_acc = chunk_df
                else:
                    df_acc = pd.concat([df_acc, chunk_df]) \
                               .groupby("term", as_index=False).sum()

                docs.clear()

    if docs:
        X = vectorizer.transform(docs)
        scores = X.sum(axis=0).A1
        chunk_df = pd.DataFrame({"term": terms, "score": scores})
        if df_acc is None:
            df_acc = chunk_df
        else:
            df_acc = pd.concat([df_acc, chunk_df]) \
                       .groupby("term", as_index=False).sum()

df_acc = df_acc.sort_values("score", ascending=False)
df_acc.to_csv(f"{OUTPUT_DIR}/partial_{WORKER_ID}.csv", index=False)

print(f"✔ Worker {WORKER_ID} completado")
