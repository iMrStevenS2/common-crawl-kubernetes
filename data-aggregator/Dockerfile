FROM python:3.11-slim

LABEL service="data-aggregator"
LABEL role="reduce"

RUN pip install pandas

WORKDIR /app
COPY aggregate.py .

VOLUME ["/data"]

CMD ["python", "aggregate.py"]
