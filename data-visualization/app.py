from flask import Flask, render_template, jsonify
import pandas as pd
import os

DATA_DIR = "/data"

app = Flask(__name__)

def load_csv(name):
    path = os.path.join(DATA_DIR, name)
    if not os.path.exists(path):
        return None
    return pd.read_csv(path)

# ---------- WEB ----------
@app.route("/")
def index():
    return render_template("index.html")

# ---------- API ----------
@app.route("/api/final_terms")
def final_terms():
    df = load_csv("final_terms_filtered.csv")
    if df is None:
        return jsonify([])
    return jsonify(df.to_dict(orient="records"))

@app.route("/api/textual_index")
def textual_index():
    df = load_csv("textual_economic_index.csv")
    if df is None:
        return jsonify([])
    return jsonify(df.to_dict(orient="records"))

@app.route("/api/colcap_relation")
def colcap_relation():
    df = load_csv("textual_colcap_relation.csv")
    if df is None:
        return jsonify({})
    return jsonify(df.to_dict(orient="records")[0])

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
