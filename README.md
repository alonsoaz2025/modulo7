# 🚀 Terraform Demo – Pipeline de Datos con BigQuery y Looker

Este proyecto crea automáticamente un **pipeline de datos completo** en Google Cloud, utilizando el dataset público de Shakespeare para demostrar las fases de:

**Ingesta → Procesamiento → Almacenamiento → Visualización**

---

## 🧩 Componentes creados
| Fase | Recurso | Descripción |
|------|----------|-------------|
| Ingesta | `google_storage_bucket` | Bucket base para pruebas |
| Procesamiento | `google_bigquery_table (view)` | Vista que agrega datos del dataset público |
| Almacenamiento | `google_bigquery_dataset` | Dataset propio del alumno |
| Visualización | Looker Studio | Conexión directa a la vista analítica |

---

## 🧰 Requisitos
- Cuenta de servicio con permisos de BigQuery y Storage
- APIs habilitadas:
  - `bigquery.googleapis.com`
  - `storage.googleapis.com`
- Archivo `credentials.json` en la raíz del proyecto

---

## ▶️ Ejecución
```bash
# 1. Autenticarse con la cuenta de servicio
gcloud auth activate-service-account --key-file=credentials.json

# 2. Inicializar Terraform
cd terraform
terraform init

# 3. Planificar
terraform plan -var="project_id=<TU_PROJECT_ID>" -var="credentials_file=../credentials.json"

# 4. Desplegar
terraform apply -auto-approve -var="project_id=<TU_PROJECT_ID>" -var="credentials_file=../credentials.json"

# 5. Conectar a Looker Studio
# Ver instrucciones al final del despliegue
