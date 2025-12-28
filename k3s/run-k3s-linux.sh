#!/usr/bin/env bash
set -e

echo "========================================"
echo " Common Crawl Pipeline - k3s (Linux)"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
YAML_DIR="$SCRIPT_DIR"

echo "Verificando cluster k3s..."
kubectl cluster-info >/dev/null

# -------------------------
# PVC
# -------------------------
echo "Aplicando PVC..."
kubectl apply -f "$YAML_DIR/data-pvc.yaml"

# -------------------------
# BUILD IMAGES (local)
# -------------------------
IMAGES=(
  data-ingestion
  data-cleaning
  data-analysis
  data-aggregator
  data-economic-index
  data-correlation
  data-visualization
)

echo "Construyendo imágenes localmente..."
for IMG in "${IMAGES[@]}"; do
  echo "→ $IMG"
  docker build -t "$IMG:latest" "$PROJECT_ROOT/$IMG"
done

# -------------------------
# PIPELINE (Jobs)
# -------------------------
STEPS=(
  data-ingestion-job.yaml
  data-cleaning-job.yaml
  data-analysis-job.yaml
  data-aggregator-job.yaml
  data-economic-index-job.yaml
  data-correlation-job.yaml
)

i=1
for STEP in "${STEPS[@]}"; do
  JOB_NAME="${STEP%-job.yaml}"
  echo "[$i/6] Ejecutando $JOB_NAME..."
  kubectl apply -f "$YAML_DIR/$STEP"
  kubectl wait --for=condition=complete "job/$JOB_NAME" --timeout=600s
  ((i++))
done

# -------------------------
# API
# -------------------------
echo "[7/7] Desplegando API..."
kubectl apply -f "$YAML_DIR/data-visualization-deployment.yaml"
kubectl apply -f "$YAML_DIR/data-visualization-service.yaml"

echo ""
echo "Pipeline k3s completado ✅"
echo "API disponible con:"
echo "kubectl port-forward svc/data-api 8080:80"
echo ""
