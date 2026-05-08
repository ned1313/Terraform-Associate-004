output "network_name" {
  description = "The name of the VPC network created by the public registry module."
  value       = module.vpc.network_name
}

output "subnet_names" {
  description = "Names of the subnets created by the public registry module."
  value       = module.vpc.subnets_names
}

output "bucket_name" {
  description = "Name of the GCS bucket holding pet records and reports."
  value       = google_storage_bucket.registry.name
}

output "pets" {
  description = "List of generated pets and their attributes."
  value       = [for o in google_storage_bucket_object.pets : jsondecode(nonsensitive(o.content))]
}

output "markdown_report_object" {
  description = "GCS object name for the markdown pet report."
  value       = module.pet_report.markdown_object_name
}

output "json_report_object" {
  description = "GCS object name for the JSON pet report."
  value       = module.pet_report.json_object_name
}
