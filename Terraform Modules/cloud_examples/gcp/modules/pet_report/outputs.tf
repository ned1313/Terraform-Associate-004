output "markdown_object_name" {
  description = "GCS object name of the rendered markdown report."
  value       = google_storage_bucket_object.markdown_report.name
}

output "json_object_name" {
  description = "GCS object name of the rendered JSON report."
  value       = google_storage_bucket_object.json_report.name
}
