FROM python:3.11-slim

LABEL service="data-economic-index"
LABEL role="analysis"

RUN pip install pandas numpy

WORKDIR /app

COPY filter_terms.py .
COPY financial_dictionary.py .
COPY classify_terms.py .
COPY economic_index.py .

VOLUME ["/data"]

CMD ["sh", "-c", "\
  rm -f /data/final_terms_filtered.csv /data/terms_with_category.csv /data/textual_economic_index.csv && \
  python filter_terms.py && \
  python classify_terms.py && \
  python economic_index.py \
"]
