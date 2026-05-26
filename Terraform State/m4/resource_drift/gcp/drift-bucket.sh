#!/usr/bin/env bash
# Updates the GCS bucket labels out-of-band to simulate resource drift.
# Sets environment=production and adds drift=true.
#
# Note: GCP uses "labels" (lowercase keys/values, restricted character set)
# where AWS and Azure use "tags". The drift concept is the same.

set -euo pipefail

# Get the bucket name from the Terraform outputs.
bucket_name=$(terraform output -raw bucket_name)
if [[ -z "$bucket_name" ]]; then
    echo "Could not read 'bucket_name' output from Terraform." >&2
    exit 1
fi

echo "Updating labels on bucket: gs://$bucket_name"

gcloud storage buckets update "gs://$bucket_name" \
    --update-labels=environment=production,drift=true >/dev/null

echo "Labels updated. Current labels:"
gcloud storage buckets describe "gs://$bucket_name" --format='value(labels)'
