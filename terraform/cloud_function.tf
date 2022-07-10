resource "google_cloudfunctions_function" "extract_gcs_load_gcs" {
    name = "function-extract-gcs-load-gcs"
    runtime = "python39"
    entry_point = "extract_gcs_load_gcs"
    event_trigger {
      event_type = "google.storage.object.finalize"
      resource = "${var.project_id}-landing"
    }
}