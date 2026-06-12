output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "The Azure region the resources are deployed into"
  value       = azurerm_resource_group.main.location
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "The ID of the public subnet"
  value       = azurerm_subnet.public.id
}
