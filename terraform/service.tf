resource "google_project_service" "data_project_services" {
  project = var.project_id
  for_each = toset(
    [
      "compute.googleapis.com",
      "bigquery.googleapis.com",
      "logging.googleapis.com",
      "serviceusage.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "iam.googleapis.com",
      "cloudfunctions.googleapis.com",
      "cloudbuild.googleapis.com",
      "appengine.googleapis.com",
      "iap.googleapis.com",
      "drive.googleapis.com"
    ]
  )
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = true
}
