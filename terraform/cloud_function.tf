resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.archive_bucket.name
  source = "../cloud_functions/extract_gcs_load_gcs"
}

resource "google_cloudfunctions_function" "extract_gcs_load_gcs" {
    name = "function-extract-gcs-load-gcs"
    runtime = "python39"
    entry_point = "extract_gcs_load_gcs"
    source_archive_bucket = google_storage_bucket.archive_bucket.name
    source_archive_object = google_storage_bucket_object.archive.name
    event_trigger {
      event_type = "google.storage.object.finalize"
      resource = "${var.project_id}-landing"
    }
}
