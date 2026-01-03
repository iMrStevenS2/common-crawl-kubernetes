# common-crawl-kubernetes

---

## Proyecto infraestructuras paralelas y distribuidas

Este proyecto implementa un pipeline de procesamiento de datos distribuido usando contenedores Docker y Kubernetes, ejecutable tanto en ***Minikube*** como en ***k3s***.

El sistema sigue un enfoque por etapas (*pipeline*), donde cada fase del procesamiento se ejecuta como un Job de Kubernetes, y el resultado final se expone mediante un servicio de visualización de datos desplegado como ***Deployment + Service***.

El proyecto fue desarrollado como prototipo funcional para demostrar:

* Ejecución concurrente de aplicaciones
* Uso de contenedores Docker
* Orquestación con *Kubernetes* (***Minikube y k3s***)
* Persistencia de datos con volúmenes (***PVC***)

### Arquitectura del sistema

El flujo general del sistema es el siguiente:

* ***Data Ingestion*** - Recolección de datos
* ***Data Cleaning*** - Limpieza y normalización
* ***Data Analysis*** - Análisis estadístico
* ***Data Aggregation*** - Agregación de resultados
* ***Data Correlation*** - Cálculo de correlaciones
* ***Economic Index*** - Cálculo de índices económicos
* ***Data Visualization*** - Visualización de resultados

#### Todas las etapas (excepto visualización) se ejecutan como Kubernetes Jobs

### Tecnologías utilizadas

* *Python 3*
* *Docker*
* *Docker Compose* (ejecución local)
* *Kubernetes*
  * *Minikube*
  * *k3s*
* *PowerShell / Bash para automatización*

---

## Ejecución del proyecto

### Opción 1: Ejecución local (sin Kubernetes en Windows)

```powershell
run_pipeline_local.ps1
```

### Opción 2: Ejecución en Minikube

1. Iniciar Minikube
2. Ejecutar:

```powershell
cd minikube
./run-minikube.ps1
```

Para exponer el servicio de visualización:

```powershell
minikube service data-api
```

### Opción 3: Ejecución en k3s

En Linux:

```bash
cd k3s
chmod +x run-k3s-linux.sh
./run-k3s-linux.sh
```

En Windows:

```powershell
cd k3s
./run-k3s.ps1
```

---

## Persistencia de datos

El proyecto utiliza un PersistentVolumeClaim (PVC) compartido entre los Jobs, lo que permite:

* Compartir resultados entre etapas.
* Evitar pérdida de datos entre ejecuciones.
* Separar procesamiento de almacenamiento.

### Visualización de datos

La visualización se ejecuta como:

* **Deployment:** servicio web persistente
* **Service:** exposición del puerto

Este componente NO es un Job, ya que debe mantenerse activo para la consulta de resultados.

---

### Autor

***Steven Bernal Ortiz***
Proyecto académico - Infraestructuras Paralelas y Distribuidas