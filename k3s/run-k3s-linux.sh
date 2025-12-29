#!/usr/bin/env bash
set -e

# ========================================
# Common Crawl Pipeline - k3s (Linux)
# ========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
YAML_DIR="$SCRIPT_DIR"

echo "Verificando cluster k3s..."
kubectl cluster-info > /dev/null

# -------------------------
# PVC
# -------------------------
echo "Aplicando PVC..."
kubectl apply -f "$YAML_DIR/data-pvc.yaml"

# -------------------------
# BUILD (containerd)
# -------------------------
echo "Construyendo imágenes (k3s / containerd)..."

IMAGES=(
  data-ingestion
  data-cleaning
  data-analysis
  data-aggregator
  data-economic-index
  data-correlation
  data-visualization
)

for IMG in "${IMAGES[@]}"; do
  echo "→ Build $IMG"
  docker build -t "$IMG:latest" "$PROJECT_ROOT/$IMG"
done

# -------------------------
# IMPORTAR imágenes a k3s
# -------------------------
echo "Importando imágenes a k3s..."
for IMG in "${IMAGES[@]}"; do
  k3s ctr images import <(docker save "$IMG:latest")
done

# -------------------------
# PIPELINE
# -------------------------
STEPS=(
  data-ingestion
  data-cleaning
  data-analysis
  data-aggregator
  data-economic-index
  data-correlation
)

i=1
for STEP in "${STEPS[@]}"; do
  echo "[$i/6] Ejecutando $STEP..."
  kubectl apply -f "$YAML_DIR/$STEP-job.yaml"
  kubectl wait --for=condition=complete "job/$STEP" --timeout=3600s
  ((i++))
done

# -------------------------
# API
# -------------------------
echo "[7/7] API..."
kubectl apply -f "$YAML_DIR/data-visualization-deployment.yaml"
kubectl apply -f "$YAML_DIR/data-visualization-service.yaml"

echo ""
echo "API disponible con:"
echo "kubectl port-forward svc/data-api 8080:80"
echo ""
echo "Pipeline k3s completado ✅"
