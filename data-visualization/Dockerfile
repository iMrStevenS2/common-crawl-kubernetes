FROM python:3.11-slim

LABEL service="data-visualization"
LABEL role="api"

WORKDIR /app

# Dependencias
RUN pip install flask pandas

# Instalar paquetes en la fase de build 
RUN apt update && apt install -y procps

# Código
COPY app.py .
COPY templates ./templates

VOLUME ["/data"]

EXPOSE 8000

CMD ["python", "app.py"]
