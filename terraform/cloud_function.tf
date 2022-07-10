data "archive_file" "source" {
    type        = "zip"
    source_dir  = "../cloud_functions/extract_gcs_load_gcs"
    output_path = "/tmp/extract_gcs_load_gcs.zip"
  depends_on = [
    random_string.r
  ]
}

resource "random_string" "r" {
  length  = 19
  special = false
}

resource "google_storage_bucket_object" "archive" {
    source       = data.archive_file.source.output_path
    content_type = "application/zip"
    name = "src-${data.archive_file.source.output_md5}.zip"
    bucket = google_storage_bucket.archive_bucket.name

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
    depends_on = [
        google_project_service.data_project_services
    ]
}
