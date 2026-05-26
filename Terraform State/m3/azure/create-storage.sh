#!/usr/bin/env bash
#
# create-storage.sh
#
# Creates an Azure Storage Account inside a new resource group and prints
# the resource group ID and storage account ID to stdout (one per line) so
# a caller can capture them for use in a Terraform `import` block.
#
# Usage:
#   ./create-storage.sh [-p PREFIX] [-g RESOURCE_GROUP] [-l LOCATION] [-s SUBSCRIPTION]
#
# Options:
#   -p PREFIX           Storage account name prefix (default: tfimportdemo).
#                       Must be lowercase letters and digits only (no hyphens).
#   -g RESOURCE_GROUP   Resource group name (default: tf-import-demo-rg).
#   -l LOCATION         Azure region (default: eastus).
#   -s SUBSCRIPTION     Optional Azure subscription ID or name.
#   -h                  Show this help.
#
# Examples:
#   read -r rg_id sa_id < <(./create-storage.sh | xargs)
#   ./create-storage.sh -p mydemo -l westus2

set -euo pipefail

prefix="tfimportdemo"
resource_group="tf-import-demo-rg"
location="eastus"
subscription=""

usage() {
    sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
}

while getopts ":p:g:l:s:h" opt; do
    case "$opt" in
        p) prefix="$OPTARG" ;;
        g) resource_group="$OPTARG" ;;
        l) location="$OPTARG" ;;
        s) subscription="$OPTARG" ;;
        h) usage; exit 0 ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage >&2; exit 2 ;;
        :)  echo "Option -$OPTARG requires an argument." >&2; exit 2 ;;
    esac
done

# Validate prefix (lowercase letters and digits only, 3-16 chars to leave
# room for the 8-character suffix while staying within the 24-char limit).
if ! [[ "$prefix" =~ ^[a-z0-9]{3,16}$ ]]; then
    echo "Invalid -p PREFIX '$prefix'. Use 3-16 lowercase letters and digits (no hyphens)." >&2
    exit 2
fi

# Ensure the Azure CLI is available.
if ! command -v az >/dev/null 2>&1; then
    echo "Azure CLI ('az') was not found in PATH. Install it from https://learn.microsoft.com/cli/azure/install-azure-cli." >&2
    exit 1
fi

# Optionally switch subscription.
if [[ -n "$subscription" ]]; then
    if ! az account set --subscription "$subscription" >/dev/null 2>&1; then
        echo "Failed to set subscription '$subscription'." >&2
        exit 1
    fi
fi

# Generate an 8-character lowercase-hex suffix for uniqueness.
if command -v openssl >/dev/null 2>&1; then
    suffix=$(openssl rand -hex 4)
else
    suffix=$(LC_ALL=C tr -dc 'a-f0-9' </dev/urandom | head -c 8)
fi

account_name="${prefix}${suffix}"

# Storage account names must be 3-24 chars, lowercase letters and digits only.
if (( ${#account_name} > 24 )); then
    echo "Generated storage account name '$account_name' exceeds 24 characters. Use a shorter -p PREFIX." >&2
    exit 1
fi
if ! [[ "$account_name" =~ ^[a-z0-9]{3,24}$ ]]; then
    echo "Generated storage account name '$account_name' is invalid." >&2
    exit 1
fi

echo "Creating resource group '$resource_group' in '$location'..." >&2
resource_group_id=$(az group create \
        --name "$resource_group" \
        --location "$location" \
        --query id \
        --output tsv)
if [[ -z "$resource_group_id" ]]; then
    echo "Failed to create resource group '$resource_group'." >&2
    exit 1
fi

echo "Creating storage account '$account_name' in resource group '$resource_group'..." >&2
storage_account_id=$(az storage account create \
        --name "$account_name" \
        --resource-group "$resource_group" \
        --location "$location" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --query id \
        --output tsv)
if [[ -z "$storage_account_id" ]]; then
    echo "Failed to create storage account '$account_name'." >&2
    exit 1
fi

# Emit the resource group ID and storage account ID on stdout (one per
# line) so callers can capture them cleanly for `terraform import` blocks.
echo "$resource_group_id"
echo "$storage_account_id"
