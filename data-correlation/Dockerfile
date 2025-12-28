FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir pandas matplotlib numpy

COPY correlate.py .
COPY clean_colcap.py .

RUN mkdir /seed

# ⚠️ copiar a una ruta NO montada
COPY colcap_investing.csv /seed/colcap_investing.csv

CMD ["sh", "-c", "python clean_colcap.py && python correlate.py"]
