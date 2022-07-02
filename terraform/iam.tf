resource "google_project_iam_binding" "sa_iam_bindings" {
  project = var.project_id
  role    = "roles/bigquery.admin"

  members = [
    "serviceAccount:${google_service_account.dbt_sa.email}",
  ]
}

resource "google_storage_bucket_iam_member" "raw_bucket" {
  bucket = "${var.project_id}-raw"
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.dbt_sa.email}",
  ]
  depends_on = [google_storage_bucket.raw_bucket]
}