FROM python:3.11-slim

LABEL service="data-cleaning"

RUN pip install beautifulsoup4 lxml warcio

WORKDIR /app
COPY clean_warc.py .

VOLUME ["/data"]

CMD ["python", "clean_warc.py"]