output "project_id" {
  description = "ID of the Google Cloud project created."
  value       = google_project.main.project_id
}

output "bucket_name" {
  description = "Name of the Cloud Storage bucket created."
  value       = google_storage_bucket.main.name
}
