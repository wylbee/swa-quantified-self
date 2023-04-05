resource "google_project_iam_binding" "sa_iam_bindings" {
  project = var.project_id
  role    = "roles/bigquery.admin"

  members = [
    "serviceAccount:${google_service_account.dbt_sa.email}",
    "serviceAccount:${google_service_account.evidence_sa.email}"
  ]
}

resource "google_storage_bucket_iam_member" "raw_bucket_view" {
  bucket = "${var.project_id}-raw"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.dbt_sa.email}"
  depends_on = [google_storage_bucket.raw_bucket]
}

resource "google_storage_bucket_iam_member" "raw_bucket_admin" {
  bucket = "${var.project_id}-raw"
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.cf_sa.email}",
    "serviceAccount:${google_service_account.dbt_sa.email}"
  ]
  depends_on = [google_storage_bucket.raw_bucket]
}

resource "google_cloudfunctions_function_iam_member" "cf_invoker" {
  project        = google_cloudfunctions_function.extract_gcs_load_gcs.project
  region         = google_cloudfunctions_function.extract_gcs_load_gcs.region
  cloud_function = google_cloudfunctions_function.extract_gcs_load_gcs.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
