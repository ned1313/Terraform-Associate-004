output "project_id" {
  description = "GCP project ID used for the deployment."
  value       = data.google_project.current.project_id
}

output "project_number" {
  description = "GCP project number."
  value       = data.google_project.current.number
}

output "region" {
  description = "GCP region used for regional resources."
  value       = data.google_client_config.current.region
}

output "bucket_name" {
  description = "Name of the GCS bucket storing the pet registry."
  value       = google_storage_bucket.pet_registry.name
}

output "cat_objects" {
  description = "GCS object names created for the cats."
  value       = [for c in google_storage_bucket_object.cats : title(c.name)]
}

output "dog_objects" {
  description = "GCS object names created for the dogs."
  value       = [for d in google_storage_bucket_object.dogs : title(d.name)]
}

output "foster_parents" {
  description = "List of foster parent names."
  value       = [for parent, pref in var.foster_parents : parent]
  sensitive   = true
}
