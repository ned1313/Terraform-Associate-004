output "markdown_blob_name" {
  description = "Blob name of the Markdown pet report."
  value       = azurerm_storage_blob.markdown_report.name
}

output "json_blob_name" {
  description = "Blob name of the JSON pet report."
  value       = azurerm_storage_blob.json_report.name
}
