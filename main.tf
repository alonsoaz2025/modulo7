# ==========================================================
# 1️⃣ INICIALIZACIÓN: STORAGE Y DATASET BASE
# ==========================================================
resource "google_storage_bucket" "demo_bucket" {
  name          = "${var.bucket_name}-${var.project_id}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id                 = var.dataset_id
  friendly_name              = "Demo Dataset Terraformizado"
  description                = "Dataset para el caso integral de pipeline de datos"
  location                   = "US"
  delete_contents_on_destroy = true
}

resource "google_billing_project_info" "project_billing" {
  project         = var.project_id
  billing_account = var.billing_account_id
}


# ==========================================================
# 2️⃣ PROCESAMIENTO: TABLA ANALÍTICA DERIVADA DE DATASET PÚBLICO
# ==========================================================
resource "google_bigquery_table" "analytics_view" {
  dataset_id = google_bigquery_dataset.demo_dataset.dataset_id
  table_id   = "shakespeare_analytics"

  view {
    query = <<EOT
    -- Vista analítica generada desde el dataset público Shakespeare
    SELECT
      corpus AS obra,
      word AS palabra,
      SUM(word_count) AS total_ocurrencias
    FROM `bigquery-public-data.samples.shakespeare`
    GROUP BY obra, palabra
    ORDER BY total_ocurrencias DESC
    LIMIT 100
    EOT
    use_legacy_sql = false
  }
}

# ==========================================================
# 3️⃣ OUTPUTS Y VISUALIZACIÓN
# ==========================================================
output "dataset_name" {
  description = "Nombre del dataset creado"
  value       = google_bigquery_dataset.demo_dataset.dataset_id
}

output "view_name" {
  description = "Nombre de la vista creada"
  value       = google_bigquery_table.analytics_view.table_id
}

output "looker_instructions" {
  description = "Instrucciones para conectar Looker Studio"
  value = <<EOT
✅ Abre https://lookerstudio.google.com/
➡️ Conecta tu cuenta de BigQuery
➡️ Selecciona el proyecto: ${var.project_id}
➡️ Dataset: ${google_bigquery_dataset.demo_dataset.dataset_id}
➡️ Vista: ${google_bigquery_table.analytics_view.table_id}
EOT
}
