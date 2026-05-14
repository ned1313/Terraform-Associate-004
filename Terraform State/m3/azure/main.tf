# Replace the values below with the resource group name and storage account
# name that were emitted by ./create-storage.ps1 or ./create-storage.sh, then
# run `terraform plan` to generate the import configuration.

resource "azurerm_resource_group" "logs" {
  name     = "tf-import-demo-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "logs" {
  name                     = "tfimportdemoffff75b5"
  resource_group_name      = azurerm_resource_group.logs.name
  location                 = azurerm_resource_group.logs.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
