resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "logs" {
  name     = "tf-state-drift-${random_string.suffix.result}"
  location = "eastus"
}

resource "azurerm_storage_account" "logs" {
  name                     = "tfstatedrift${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.logs.name
  location                 = azurerm_resource_group.logs.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "resource_group_name" {
  value = azurerm_resource_group.logs.name
}

output "storage_account_name" {
  value = azurerm_storage_account.logs.name
}
