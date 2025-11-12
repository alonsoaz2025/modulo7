#!/bin/bash
# ======================================================
# SCRIPT DE CREACIÓN DE PROYECTO GCP – SIN ORGANIZACIÓN
# ======================================================
set -u
# -----------------------------
# 1️⃣ VARIABLES CONFIGURABLES
# -----------------------------
export BILLING_ACCOUNT="016D51-A387E0-FACB76"
export PROJECT_ID="project-bigdata-final"
export PROJECT_NAME="Project-BigData-Try-2"
export REGION="us-east1"
export ZONE="us-east1-b"
export LABELS="env=prd,owner=data,team=data-eng,domain=data,costcenter=business-intelligence"
export SA_NAME="github-iac-terraform"
export SA_DISPLAY_NAME="GitHub Terraform Service Account"
echo -e "\033[1;34m🚀 Iniciando configuración de entorno GCP para Terraform...\033[0m"
# -----------------------------
# 2️⃣ LIMPIAR CONTEXTO ACTIVO
# -----------------------------
echo "🧹 Limpiando contexto activo..."
gcloud config unset project || true
# ---------------------------------------
# 3️⃣ CREAR PROYECTO Y CUENTA DE SERVICIO
# ----------------------------------------------------
echo "🏗️ Creando proyecto $PROJECT_ID ..."
gcloud projects create $PROJECT_ID --name="$PROJECT_NAME" --set-as-default --quiet
echo -e "\033[1;33m🔐 Creando cuenta de servicio: $SA_NAME...\033[0m"
gcloud iam service-accounts create $SA_NAME \
  --display-name="$SA_DISPLAY_NAME" \
  --project=$PROJECT_ID \
  --quiet || echo "ℹ️ La cuenta ya existe, continuando..."
# -----------------------------
# 4️⃣ VINCULAR BILLING
# ------------------------------------------
echo "💳 Vinculando cuenta de facturación..."
gcloud beta billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT --quiet
# -----------------------------
# 5️⃣ CONFIGURAR REGIÓN Y ZONA
# -----------------------------
echo "🌎 Configurando región y zona..."
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
# -----------------------------
# 6️⃣APLICAR ETIQUETAS (LABELS)
# -----------------------------
echo "🏷️ Aplicando etiquetas..."
for i in {1..5}; do
  if gcloud alpha projects update $PROJECT_ID --update-labels=$LABELS; then
    echo "✅ Etiquetas aplicadas correctamente."
    break
  else
    echo "⏳ Falló el intento $i aplicando etiquetas, reintentando en 10s..."
    sleep 10
  fi
done || echo "⚠️ No se pudieron aplicar etiquetas después de varios intentos, continúa el flujo."
echo "🔎 Verificando etiquetas..."
gcloud projects describe $PROJECT_ID --format="yaml(labels)"
# -----------------------------
# 7️⃣ ACTIVAR APIS ESENCIALES
# -----------------------------
echo "⚙️ Habilitando APIs..."
APIS=(
  compute.googleapis.com
  iam.googleapis.com
  cloudresourcemanager.googleapis.com
  serviceusage.googleapis.com
  storage.googleapis.com
  bigquery.googleapis.com
  dataflow.googleapis.com
  logging.googleapis.com
  monitoring.googleapis.com
)
for api in "${APIS[@]}"; do
  echo "🔧 Habilitando $api ..."
  gcloud services enable $api --project=$PROJECT_ID --quiet || echo "⚠️ API $API ya habilitada."
  echo "⏳ Esperando 60 segundos para propagación de $api ..."
  sleep 60
done
echo "✅ Todas las APIs esenciales habilitadas correctamente."
# -----------------------------
# 8️⃣ ASIGNAR ROLES NECESARIOS
# -----------------------------
echo -e "\033[1;33m🧾 Asignando roles a la cuenta de servicio...\033[0m"

for ROLE in roles/editor roles/storage.admin roles/bigquery.admin roles/logging.admin roles/iam.serviceAccountUser
do
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="$ROLE" \
    --quiet || echo "⚠️ Rol $ROLE ya asignado o sin cambios."
done
# -----------------------------
# 9️⃣ VALIDAR CONFIGURACIÓN FINAL
# -----------------------------
echo "------------------------------------------------------"
echo "🔎 Validando creación del proyecto..."
gcloud projects describe $PROJECT_ID --format="table(projectId,name,lifecycleState)"
echo "------------------------------------------------------"
echo "✅ Billing asociado:"
gcloud alpha billing accounts projects list --billing-account=$BILLING_ACCOUNT | grep $PROJECT_ID || echo "⚠️ No vinculado"
echo "------------------------------------------------------"
echo "✅ Región/Zona actual:"
gcloud config list compute
echo "------------------------------------------------------"
echo "✅ Etiquetas aplicadas:"
gcloud resource-manager labels list --project=$PROJECT_ID
echo "------------------------------------------------------"
echo "✅ APIs habilitadas:"
gcloud services list --enabled --project=$PROJECT_ID | grep -E "compute|storage|bigquery|dataflow|monitoring|logging"
echo "------------------------------------------------------"
echo "🎉 Proyecto $PROJECT_ID creado y configurado correctamente."
echo -e "\n⚠️  Ahora crea la key JSON manualmente con:\n"
echo -e "   gcloud iam service-accounts keys create credentials.json \\"
echo -e "     --iam-account=${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \\"
echo -e "     --project=${PROJECT_ID}\n"
echo -e "Luego sube su contenido como secret en GitHub → Settings → Secrets → Actions → GOOGLE_CREDENTIALS"
# ==========================================================
# 🔟 GENERAR ARCHIVOS TERRAFORM
# ==========================================================
echo -e "\033[1;33m📂 Generando estructura base de Terraform...\033[0m"
mkdir -p $TF_DIR

cat > $TF_DIR/terraform.tfvars <<EOF
# ==========================================================
# VALORES DE VARIABLES PARA EL PROYECTO ACTUAL
# ==========================================================
project_id         = "$PROJECT_ID"
region             = "$REGION"
billing_account_id = "$BILLING_ACCOUNT"
bucket_name        = "demo-data-bucket"
dataset_id         = "demo_dataset"
EOF
