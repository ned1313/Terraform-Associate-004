#requires -Version 5.1
<#
.SYNOPSIS
    Creates an Azure Storage Account inside a new resource group and returns
    the resource group ID and storage account ID.

.DESCRIPTION
    Generates a globally-unique storage account name using a prefix plus a
    short random suffix, creates a resource group, and then creates the
    storage account in that resource group using the Azure CLI. The resource
    group ID and storage account ID (full ARM resource IDs) are written to
    stdout (one per line) so a caller can capture them for use in a
    Terraform `import` block.

.PARAMETER Prefix
    Prefix for the storage account name. Must be lowercase letters and
    digits only (no hyphens). Defaults to "tfimportdemo".

.PARAMETER ResourceGroup
    Name of the resource group to create. Defaults to "tf-import-demo-rg".

.PARAMETER Location
    Azure region in which to create the resource group and storage account.
    Defaults to "eastus".

.PARAMETER Subscription
    Optional Azure subscription ID or name to use for the operation.

.EXAMPLE
    PS> ./create-storage.ps1
    /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/tf-import-demo-rg
    /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/tf-import-demo-rg/providers/Microsoft.Storage/storageAccounts/tfimportdemoa1b2c3d4

.EXAMPLE
    PS> $out   = ./create-storage.ps1 -Prefix "mydemo" -Location "westus2"
    PS> $rgId  = $out[0]
    PS> $saId  = $out[1]
#>
[CmdletBinding()]
param(
    [ValidatePattern('^[a-z0-9]{3,16}$')]
    [string]$Prefix = 'tfimportdemo',

    [string]$ResourceGroup = 'tf-import-demo-rg',

    [string]$Location = 'eastus',

    [string]$Subscription
)

$ErrorActionPreference = 'Stop'

# Ensure the Azure CLI is available.
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI ('az') was not found in PATH. Install it from https://learn.microsoft.com/cli/azure/install-azure-cli."
}

# Optionally switch subscription.
if ($PSBoundParameters.ContainsKey('Subscription') -and $Subscription) {
    Write-Verbose "Setting active subscription to '$Subscription'..."
    $null = & az account set --subscription $Subscription 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set subscription '$Subscription' (az exit code $LASTEXITCODE)."
    }
}

# Generate an 8-character lowercase-hex suffix for uniqueness.
$suffix = -join ((1..8) | ForEach-Object {
    '{0:x}' -f (Get-Random -Minimum 0 -Maximum 16)
})
$accountName = "$Prefix$suffix"

# Storage account names must be 3-24 chars, lowercase letters and digits only.
if ($accountName.Length -gt 24) {
    throw "Generated storage account name '$accountName' exceeds 24 characters. Use a shorter -Prefix."
}
if ($accountName -notmatch '^[a-z0-9]{3,24}$') {
    throw "Generated storage account name '$accountName' is invalid. Must be 3-24 lowercase letters/digits."
}

Write-Verbose "Creating resource group '$ResourceGroup' in '$Location'..."
$resourceGroupId = & az group create `
    --name $ResourceGroup `
    --location $Location `
    --query id `
    --output tsv
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($resourceGroupId)) {
    throw "Failed to create resource group '$ResourceGroup' (az exit code $LASTEXITCODE)."
}

Write-Verbose "Creating storage account '$accountName' in resource group '$ResourceGroup'..."
$storageAccountId = & az storage account create `
    --name $accountName `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --query id `
    --output tsv
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($storageAccountId)) {
    throw "Failed to create storage account '$accountName' (az exit code $LASTEXITCODE)."
}

# Emit the resource group ID and storage account ID on stdout (one per
# line) so callers can capture them cleanly for `terraform import` blocks.
$resourceGroupId
$storageAccountId
