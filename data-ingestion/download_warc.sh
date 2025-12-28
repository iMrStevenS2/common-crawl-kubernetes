#!/bin/bash

CRAWL="CC-MAIN-2025-38"
BASE_URL="https://data.commoncrawl.org"
OUTPUT_DIR="/data/raw"
NUM_FILES=${NUM_FILES:-10}

mkdir -p "$OUTPUT_DIR"

echo "Descargando listado WARC (${CRAWL})..."
wget -q ${BASE_URL}/crawl-data/${CRAWL}/warc.paths.gz -O /tmp/warc.paths.gz
gunzip -f /tmp/warc.paths.gz

head -n $NUM_FILES /tmp/warc.paths > /tmp/warc.sample

echo "Descargando $NUM_FILES archivos WARC:"
cat /tmp/warc.sample

while read -r path; do
    echo "Descargando $path"
    wget -c "${BASE_URL}/${path}" -P "$OUTPUT_DIR" || {
        echo "⚠️ Falló $path, continuando..."
    }
done < /tmp/warc.sample



echo "✔ Descarga completada"
