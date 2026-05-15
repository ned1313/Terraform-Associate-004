output "resource_group_name" {
  description = "Name of the resource group holding all pet registry resources."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "ID of the VNet created by the public registry module."
  value       = module.vnet.resource_id
}

output "subnet_ids" {
  description = "IDs of the subnets created by the public registry module."
  value       = [for k, s in module.vnet.subnets : s.resource_id]
}

output "storage_account_name" {
  description = "Name of the Storage Account holding the reports container and pet registry table."
  value       = azurerm_storage_account.reports.name
}

output "container_name" {
  description = "Name of the blob container holding the generated pet reports."
  value       = azurerm_storage_container.reports.name
}

output "pets" {
  description = "The registered pets."
  value       = local.pets
}

output "markdown_report_blob" {
  description = "Blob name of the rendered Markdown report."
  value       = module.pet_report.markdown_blob_name
}

output "json_report_blob" {
  description = "Blob name of the rendered JSON report."
  value       = module.pet_report.json_blob_name
}
