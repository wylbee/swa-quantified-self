resource "google_storage_bucket" "landing_bucket" {
    name     = "${var.project_id}-landing"
    location = var.region
}