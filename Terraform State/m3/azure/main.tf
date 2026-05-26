# Replace the values in the import blocks belows with the resource group ID
# and storage account ID that were emitted by the create-storage script. Then
# run `terraform plan -generate-config-out=imports.tf` to generate the import configuration.

resource "azurerm_resource_group" "logs" {
  name     = "tf-import-demo-rg"
  location = "eastus"
}

import {
  to = azurerm_resource_group.logs
  id= "RESOURCE_GROUP_ID"
}

import {
  to = azurerm_storage_account.logs
  id= "STORAGE_ACCOUNT_ID"
}
