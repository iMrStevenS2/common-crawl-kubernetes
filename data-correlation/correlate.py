import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

TEXTUAL = "/data/textual_economic_index.csv"
COLCAP = "/data/colcap_clean.csv"
OUT = "/data/textual_colcap_relation.csv"

textual = pd.read_csv(TEXTUAL)
colcap = pd.read_csv(COLCAP)

textual_index = textual["final_score"].sum()
colcap_returns = colcap["close"].pct_change().dropna()

result = pd.DataFrame([{
    "textual_index": textual_index,
    "colcap_mean_return": colcap_returns.mean(),
    "colcap_volatility": colcap_returns.std()
}])

result.to_csv(OUT, index=False)

# Plot
plt.figure()
plt.bar(
    ["Textual Index", "Mean Return", "Volatility"],
    result.iloc[0].values
)
plt.title("Relación entre Índice Textual Económico y COLCAP")
plt.tight_layout()
plt.savefig("/data/textual_colcap_relation.png")
