# ========================================
# Common Crawl Distributed Pipeline (Local)
# ========================================

$ANALYSIS_WORKERS = 3
$CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "[1/7] Limpiando datos..."
New-Item -ItemType Directory -Force "$CurrentDir\data\raw","$CurrentDir\data\clean","$CurrentDir\data\analysis" | Out-Null
Remove-Item "$CurrentDir\data\clean\*.txt","$CurrentDir\data\analysis\*.csv" -ErrorAction SilentlyContinue


Write-Host "[2/7] Build imágenes..."
docker build -t data-ingestion ./data-ingestion
docker build -t data-cleaning ./data-cleaning
docker build -t data-analysis ./data-analysis
docker build -t data-aggregator ./data-aggregator
docker build -t data-economic-index ./data-economic-index
docker build -t data-correlation ./data-correlation
docker build -t data-visualization ./data-visualization

Write-Host "[3/7] Ingestion..."
docker run --rm -v "$CurrentDir\data:/data" data-ingestion

# Temporal: saltar análisis
Write-Host "[4/7] Cleaning..."
docker run --rm -v "$CurrentDir\data:/data" data-cleaning
Write-Host "⚠️ Saltando etapa de limpieza (temporal)"

Write-Host "[5/7] Analysis ($ANALYSIS_WORKERS workers)..."
$jobs=@()

for ($i=0; $i -lt $ANALYSIS_WORKERS; $i++) {
  $jobs += Start-Job {
    param($i,$dir,$total)
    docker run --rm `
      -e WORKER_ID=$i `
      -e TOTAL_WORKERS=$total `
      -v "$dir\data:/data" `
      data-analysis
  } -ArgumentList $i,$CurrentDir,$ANALYSIS_WORKERS
}

Wait-Job $jobs | Out-Null


Write-Host "[6/7] Aggregation + Index..."
docker run --rm -v "$CurrentDir\data:/data" data-aggregator
docker run --rm -v "$CurrentDir\data:/data" data-economic-index
docker run --rm -v "$CurrentDir\data:/data" data-correlation

Write-Host "[7/7] API..."
docker run --rm -p 8000:8000 -v "$CurrentDir\data:/data" data-visualization
