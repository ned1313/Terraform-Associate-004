resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "google_storage_bucket" "logs" {
  name                        = "tf-resource-drift-${random_string.suffix.result}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  labels = {
    environment = "development"
  }
}

output "bucket_name" {
  value = google_storage_bucket.logs.name
}

output "bucket_location" {
  value = google_storage_bucket.logs.location
}
