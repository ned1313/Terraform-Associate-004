#!/usr/bin/env bash
#
# create-bucket.sh
#
# Creates a Google Cloud Storage bucket with a unique name and prints the
# bucket name to stdout so a caller can capture it (e.g. for use in a
# Terraform `import` block).
#
# Usage:
#   ./create-bucket.sh [-p PREFIX] [-l LOCATION] [-P PROJECT]
#
# Options:
#   -p PREFIX     Bucket name prefix (default: tf-import-demo).
#                 Must be DNS-compliant: lowercase letters, digits, hyphens.
#   -l LOCATION   GCS location/region (default: US).
#   -P PROJECT    GCP project ID. If omitted, uses the active gcloud project.
#   -h            Show this help.
#
# Examples:
#   bucket=$(./create-bucket.sh)
#   bucket=$(./create-bucket.sh -p my-demo -l us-central1 -P my-project-id)

set -euo pipefail

prefix="tf-import-demo"
location="US"
project=""

usage() {
    sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
}

while getopts ":p:l:P:h" opt; do
    case "$opt" in
        p) prefix="$OPTARG" ;;
        l) location="$OPTARG" ;;
        P) project="$OPTARG" ;;
        h) usage; exit 0 ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage >&2; exit 2 ;;
        :)  echo "Option -$OPTARG requires an argument." >&2; exit 2 ;;
    esac
done

# Validate prefix (DNS-compliant, 3-32 chars to leave room for the suffix).
if ! [[ "$prefix" =~ ^[a-z0-9]([a-z0-9-]{1,30}[a-z0-9])?$ ]]; then
    echo "Invalid -p PREFIX '$prefix'. Use lowercase letters, digits, and hyphens." >&2
    exit 2
fi

# Ensure the gcloud CLI is available.
if ! command -v gcloud >/dev/null 2>&1; then
    echo "gcloud CLI was not found in PATH. Install it from https://cloud.google.com/sdk/docs/install." >&2
    exit 1
fi

# Resolve the target project.
if [[ -z "$project" ]]; then
    project=$(gcloud config get-value project 2>/dev/null || true)
    if [[ -z "$project" || "$project" == "(unset)" ]]; then
        echo "No GCP project specified and no active gcloud project is set. Pass -P or run 'gcloud config set project <ID>'." >&2
        exit 1
    fi
fi

# Generate an 8-character lowercase-hex suffix for uniqueness.
if command -v openssl >/dev/null 2>&1; then
    suffix=$(openssl rand -hex 4)
else
    suffix=$(LC_ALL=C tr -dc 'a-f0-9' </dev/urandom | head -c 8)
fi

bucket_name="${prefix}-${suffix}"

# GCS bucket names must be 3-63 chars (for non-domain names).
if (( ${#bucket_name} > 63 )); then
    echo "Generated bucket name '$bucket_name' exceeds 63 characters. Use a shorter -p PREFIX." >&2
    exit 1
fi

echo "Creating GCS bucket 'gs://$bucket_name' in project '$project' (location: $location)..." >&2

if ! gcloud storage buckets create "gs://$bucket_name" \
        --project "$project" \
        --location "$location" \
        --uniform-bucket-level-access >/dev/null; then
    echo "Failed to create GCS bucket '$bucket_name'." >&2
    exit 1
fi

# Emit only the bucket name on stdout so callers can capture it cleanly.
echo "$bucket_name"
