FROM python:3.11-slim

LABEL service="data-analysis"

RUN pip install scikit-learn pandas

WORKDIR /app
COPY analyze.py .

VOLUME ["/data"]

CMD ["python", "analyze.py"]
