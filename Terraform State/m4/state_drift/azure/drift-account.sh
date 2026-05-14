#!/usr/bin/env bash
# Rotates the storage account's primary access key out-of-band to simulate
# state drift on an attribute that Terraform exports as read-only but does
# not manage as a configurable input.
#
# `primary_access_key` is a computed-only exported attribute on
# azurerm_storage_account. Refresh will pick up the new value and update
# state, but `terraform plan` will not propose any changes because nothing
# in the configuration references the key as an input.

set -euo pipefail

rg_name=$(terraform output -raw resource_group_name)
if [[ -z "$rg_name" ]]; then
    echo "Could not read 'resource_group_name' output from Terraform." >&2
    exit 1
fi

account_name=$(terraform output -raw storage_account_name)
if [[ -z "$account_name" ]]; then
    echo "Could not read 'storage_account_name' output from Terraform." >&2
    exit 1
fi

echo "Regenerating primary access key on storage account: $account_name ($rg_name)"

az storage account keys renew \
    --resource-group "$rg_name" \
    --account-name "$account_name" \
    --key primary >/dev/null

echo "Primary key rotated. Current keys (truncated):"
az storage account keys list \
    --resource-group "$rg_name" \
    --account-name "$account_name" \
    --query "[].{name:keyName, value:join('', [value][:1])}" \
    --output table
