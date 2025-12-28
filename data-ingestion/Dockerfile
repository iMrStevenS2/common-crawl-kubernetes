FROM ubuntu:22.04

LABEL service="data-ingestion"
LABEL description="Descarga de archivos WARC desde Common Crawl"

RUN apt-get update && \
    apt-get install -y wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY download_warc.sh .
RUN chmod +x download_warc.sh

VOLUME ["/data"]
CMD ["./download_warc.sh"]
