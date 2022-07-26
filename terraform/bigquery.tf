resource "google_bigquery_dataset" "gcs_raw_dataset" {
  project                     = var.project_id
  dataset_id                  = "gcs_raw"
  friendly_name               = "gcs_raw"
  description                 = "External tables for the raw GCS bucket."
  location                    = var.region
  default_table_expiration_ms = 3600000

  access {
    role          = "WRITER"
    user_by_email = google_service_account.dbt_sa.email
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.bq_owner.email
  }
}