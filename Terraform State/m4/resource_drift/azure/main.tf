resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "logs" {
  name     = "tf-resource-drift-${random_string.suffix.result}"
  location = "eastus"

  tags = {
    Environment = "Development"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.logs.name
}

output "resource_group_location" {
  value = azurerm_resource_group.logs.location
}
