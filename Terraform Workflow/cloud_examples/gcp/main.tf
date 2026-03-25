provider "google" {
  region = var.region
}

resource "random_id" "project" {
  byte_length = 4
}

resource "google_project" "main" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.project.hex}"
  billing_account = var.billing_account
  org_id          = var.org_id
}

resource "google_project_service" "storage" {
  project = google_project.main.project_id
  service = "storage.googleapis.com"
}

resource "google_storage_bucket" "main" {
  name          = "${var.bucket_name_prefix}-${random_id.project.hex}"
  location      = var.region
  project       = google_project.main.project_id
  force_destroy = true

  depends_on = [google_project_service.storage]
}
