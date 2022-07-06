# Bigquery Owner
resource "google_service_account" "bq_owner" {
  account_id = "bq-owner"
  project    = var.project_id
}

# dbt service account
resource "google_service_account" "dbt_sa" {
  account_id   = "dbt-runner"
  project      = var.project_id
  display_name = "dbt Service Account"
  description  = "dbt service account"
}
# dbt service account key
resource "google_service_account_key" "dbt_sa_key" {
  service_account_id = google_service_account.dbt_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# cf service account
resource "google_service_account" "cf_sa" {
  account_id   = "cf-runner"
  project      = var.project_id
  display_name = "Cloud Function Service Account"
  description  = "Cloud Function service account"
}
# cf service account key
resource "google_service_account_key" "cf_sa_key" {
  service_account_id = google_service_account.cf_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}