# ========================================
# Common Crawl Pipeline - k3s
# ========================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir\.."
$YamlDir = $ScriptDir

$REGISTRY = "localhost:5000"

Write-Host "Verificando cluster k3s..."
kubectl cluster-info | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "k3s no está activo"
    exit 1
}

# -------------------------
# PVC
# -------------------------
Write-Host "Aplicando PVC..."
kubectl apply -f "$YamlDir\data-pvc.yaml"

# -------------------------
# BUILD & PUSH
# -------------------------
Write-Host "Construyendo y publicando imágenes en registry local..."

$images = @(
  "data-ingestion",
  "data-cleaning",
  "data-analysis",
  "data-aggregator",
  "data-economic-index",
  "data-correlation",
  "data-visualization"
)

foreach ($img in $images) {
    docker build -t "$REGISTRY/$img:latest" "$ProjectRoot\$img"
    docker push "$REGISTRY/$img:latest"
}

# -------------------------
# PIPELINE
# -------------------------
$steps = @(
  @{ name = "Ingestion"; file = "data-ingestion-job.yaml" },
  @{ name = "Cleaning"; file = "data-cleaning-job.yaml" },
  @{ name = "Analysis"; file = "data-analysis-job.yaml" },
  @{ name = "Aggregation"; file = "data-aggregator-job.yaml" },
  @{ name = "Economic Index"; file = "data-economic-index-job.yaml" },
  @{ name = "Correlation"; file = "data-correlation-job.yaml" }
)

$i = 1
foreach ($step in $steps) {
    Write-Host "[$i/6] $($step.name)..."
    kubectl apply -f "$YamlDir\$($step.file)"
    kubectl wait --for=condition=complete "job/$(($step.file -replace '-job.yaml',''))" --timeout=600s
    $i++
}

# -------------------------
# API
# -------------------------
Write-Host "[7/7] API..."
kubectl apply -f "$YamlDir\data-visualization-deployment.yaml"
kubectl apply -f "$YamlDir\data-visualization-service.yaml"

Write-Host ""
Write-Host "API disponible con:"
Write-Host "kubectl port-forward svc/data-api 8080:80"
Write-Host ""
Write-Host "Pipeline k3s completado ✅"
