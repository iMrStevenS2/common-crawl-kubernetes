Write-Host "========================================"
Write-Host "Borrando pods y recursos previos... "
Write-Host "========================================"

# Borrar pods de etapas previas
kubectl delete job data-ingestion --ignore-not-found
kubectl delete job data-cleaning --ignore-not-found
kubectl delete job data-analysis --ignore-not-found
kubectl delete job data-aggregator --ignore-not-found
kubectl delete job data-economic-index --ignore-not-found
kubectl delete job data-correlation --ignore-not-found
kubectl delete job data-visualization --ignore-not-found

kubectl delete deployment data-visualization-deployment --ignore-not-found

# (Opcional) borrar PV y PVC si quieres reiniciar los datos completamente
kubectl delete pvc data-pvc --ignore-not-found
kubectl delete pv data-pv --ignore-not-found
