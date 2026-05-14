#!/usr/bin/env bash
# Updates the resource group tags out-of-band to simulate resource drift.
# Sets Environment=Production and adds Drift=True.

set -euo pipefail

# Get the resource group name and location from the Terraform outputs.
rg_name=$(terraform output -raw resource_group_name)
if [[ -z "$rg_name" ]]; then
    echo "Could not read 'resource_group_name' output from Terraform." >&2
    exit 1
fi

rg_location=$(terraform output -raw resource_group_location)
if [[ -z "$rg_location" ]]; then
    echo "Could not read 'resource_group_location' output from Terraform." >&2
    exit 1
fi

echo "Updating tags on resource group: $rg_name ($rg_location)"

az group update \
    --name "$rg_name" \
    --set tags.Environment=Production tags.Drift=True >/dev/null

echo "Tags updated. Current tagging:"
az group show --name "$rg_name" --query tags
