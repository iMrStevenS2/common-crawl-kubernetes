# Ejecutar comandos dentro de la carpeta Minikube
# Ingestion
minikube docker-env
docker build -t data-ingestion ../data-ingestion
minikube image load data-ingestion

# recrear job
kubectl delete job data-ingestion
kubectl apply -f data-ingestion-job.yaml

# Cleaning
minikube docker-env
docker build -t data-cleaning ../data-cleaning
minikube image load data-cleaning

# recrear job
kubectl delete job data-cleaning
kubectl apply -f data-cleaning-job.yaml

# Analysis
minikube docker-env
docker build -t data-analysis ../data-analysis

# recrear job
kubectl delete job data-analysis
kubectl apply -f data-analysis-job.yaml

#  Aggregator
minikube docker-env
docker build -t data-aggregator ../data-aggregator
minikube image load data-aggregator

# recrear job
kubectl delete job data-aggregator
kubectl apply -f data-aggregator-job.yaml

# Economic Index
minikube docker-env
docker build -t data-economic-index ../data-economic-index
minikube image load data-economic-index

# recrear job
kubectl delete job data-economic-index
kubectl apply -f data-economic-index-job.yaml

# Correlation
minikube docker-env
docker build -t data-correlation ../data-correlation
minikube image load data-correlation

# recrear job
kubectl delete job data-correlation
kubectl apply -f data-correlation-job.yaml