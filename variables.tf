variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región donde se desplegará la infraestructura"
  type        = string
}

variable "billing_account_id" {
  description = "ID de la cuenta de facturación asociada al proyecto"
  type        = string
}

variable "google_credentials" {
  description = "Credenciales JSON de la cuenta de servicio (desde secreto GitHub)"
  type        = string
}

variable "dataset_id" {
  description = "Dataset de BigQuery a crear"
  type        = string
}

variable "bucket_name" {
  description = "Bucket de almacenamiento para pruebas"
  type        = string
}
