output "location" {
  description = "Azure region the pet registry was deployed into."
  value       = azurerm_resource_group.main.location
}

output "subscription_id" {
  description = "Azure subscription ID used for the deployment."
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Azure AD tenant ID used for the deployment."
  value       = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the storage account holding the pet registry."
  value       = azurerm_storage_account.pet_registry.name
}

output "cat_blobs" {
  description = "Blob names created for the cats."
  value       = [for c in azurerm_storage_blob.cats : title(c.name)]
}

output "dog_blobs" {
  description = "Blob names created for the dogs."
  value       = [for d in azurerm_storage_blob.dogs : title(d.name)]
}

output "foster_parents" {
  description = "List of foster parent names."
  value       = [for parent, pref in var.foster_parents : parent]
  sensitive   = true
}
