# Rotates the storage account's primary access key out-of-band to simulate
# state drift on an attribute that Terraform exports as read-only but does
# not manage as a configurable input.
#
# `primary_access_key` is a computed-only exported attribute on
# azurerm_storage_account. Refresh will pick up the new value and update
# state, but `terraform plan` will not propose any changes because nothing
# in the configuration references the key as an input.

$ErrorActionPreference = 'Stop'

$rgName = terraform output -raw resource_group_name
if ([string]::IsNullOrWhiteSpace($rgName)) {
    throw "Could not read 'resource_group_name' output from Terraform."
}

$accountName = terraform output -raw storage_account_name
if ([string]::IsNullOrWhiteSpace($accountName)) {
    throw "Could not read 'storage_account_name' output from Terraform."
}

Write-Host "Regenerating primary access key on storage account: $accountName ($rgName)"

az storage account keys renew `
    --resource-group $rgName `
    --account-name $accountName `
    --key primary | Out-Null

Write-Host "Primary key rotated. Current keys (truncated):"
az storage account keys list `
    --resource-group $rgName `
    --account-name $accountName `
    --query "[].{name:keyName, value:join('', [value][:1])}" `
    --output table
