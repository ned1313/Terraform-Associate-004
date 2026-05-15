output "pets" {
  description = "The generated pets."
  value       = module.pet-registry.pets
}

output "markdown_report_filename" {
  value = module.pet_report.markdown_filename
}

output "json_report_filename" {
  value = module.pet_report.json_filename
}