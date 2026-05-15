output "markdown_filename" {
  description = "The path to the generated Markdown pet report."
  value       = local_file.markdown_report.filename
}

output "json_filename" {
  description = "The path to the generated JSON pet report."
  value       = local_file.json_report.filename
}