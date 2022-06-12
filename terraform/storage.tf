resource "google_storage_bucket" "landing_bucket" {
    name     = "${var.project_id}-landing"
    location = var.region
}

resource "google_storage_bucket" "raw_bucket" {
    name     = "${var.project_id}-raw"
    location = var.region
}

resource "google_storage_bucket" "archive_bucket" {
    name     = "${var.project_id}-archive"
    location = var.region
}
