# Updates the resource group tags out-of-band to simulate resource drift.
# Sets Environment=Production and adds Drift=True.

$ErrorActionPreference = 'Stop'

# Get the resource group name and location from the Terraform outputs.
$rgName = terraform output -raw resource_group_name
if ([string]::IsNullOrWhiteSpace($rgName)) {
    throw "Could not read 'resource_group_name' output from Terraform."
}

$rgLocation = terraform output -raw resource_group_location
if ([string]::IsNullOrWhiteSpace($rgLocation)) {
    throw "Could not read 'resource_group_location' output from Terraform."
}

Write-Host "Updating tags on resource group: $rgName ($rgLocation)"

# `az group update --set tags=...` replaces the entire tag map, mirroring
# the `put-bucket-tagging` behavior in the AWS script.
az group update `
    --name $rgName `
    --set tags.Environment=Production tags.Drift=True | Out-Null

Write-Host "Tags updated. Current tagging:"
az group show --name $rgName --query tags
