# ========================================
# Common Crawl Pipeline - Minikube
# ========================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir\.."
$YamlDir = $ScriptDir

Write-Host "Iniciando Minikube..."
minikube start --driver=docker

# ---------- MINIKUBE ----------
minikube status | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Minikube no está activo"
  exit 1
}

Write-Host "Configurando Docker para Minikube..."
& minikube -p minikube docker-env --shell powershell | Invoke-Expression


# -------------------------
# PVC
# -------------------------
Write-Host "Aplicando PersistentVolumeClaim..."
kubectl apply -f "$YamlDir\data-pvc.yaml"

# ---------- BUILD ----------
docker build -t data-ingestion "$ProjectRoot\data-ingestion"
docker build -t data-cleaning "$ProjectRoot\data-cleaning"
docker build -t data-analysis "$ProjectRoot\data-analysis"
docker build -t data-aggregator "$ProjectRoot\data-aggregator"
docker build -t data-economic-index "$ProjectRoot\data-economic-index"
docker build -t data-correlation "$ProjectRoot\data-correlation"
docker build -t data-visualization "$ProjectRoot\data-visualization"

# # ---------- LOAD ----------
# minikube image load data-ingestion
# minikube image load data-cleaning
# minikube image load data-analysis
# minikube image load data-aggregator
# minikube image load data-economic-index
# minikube image load data-correlation
# minikube image load data-visualization

# -------------------------
# INGESTION
# -------------------------
Write-Host "[1/7] Ingestion..."
kubectl apply -f "$YamlDir\data-ingestion-job.yaml"
kubectl wait --for=condition=complete job/data-ingestion --timeout=600s

# -------------------------
# CLEANING
# -------------------------
Write-Host "[2/7] Cleaning..."
kubectl apply -f "$YamlDir\data-cleaning-job.yaml"
kubectl wait --for=condition=complete job/data-cleaning

# -------------------------
# ANALYSIS (PARALELO)
# -------------------------
Write-Host "[3/7] Analysis (parallel workers)..."
kubectl apply -f "$YamlDir\data-analysis-job.yaml"
kubectl wait --for=condition=complete job/data-analysis

# -------------------------
# AGGREGATION
# -------------------------
Write-Host "[4/7] Aggregation..."
kubectl apply -f "$YamlDir\data-aggregator-job.yaml"
kubectl wait --for=condition=complete job/data-aggregator

# -------------------------
# ECONOMIC INDEX
# -------------------------
Write-Host "[5/7] Economic Index..."
kubectl apply -f "$YamlDir\data-economic-index-job.yaml"
kubectl wait --for=condition=complete job/data-economic-index

# -------------------------
# CORRELATION
# -------------------------
Write-Host "[6/7] Correlation..."
kubectl apply -f "$YamlDir\data-correlation-job.yaml"
kubectl wait --for=condition=complete job/data-correlation

# -------------------------
# API
# -------------------------
Write-Host "[7/7] API..."
kubectl apply -f "$YamlDir\data-visualization-deployment.yaml"
kubectl apply -f "$YamlDir\data-visualization-service.yaml"

Write-Host "Esperando a que la API esté lista..."
kubectl rollout status deployment/data-visualization --timeout=120s

Write-Host "Abriendo API..."
minikube service data-api