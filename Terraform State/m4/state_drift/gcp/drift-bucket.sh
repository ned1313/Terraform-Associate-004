#!/usr/bin/env bash
# Changes the GCS bucket soft-delete retention duration out-of-band to
# simulate state drift on an attribute that Terraform tracks as
# Optional+Computed but that this configuration does not manage.
#
# `soft_delete_policy` is Optional+Computed on google_storage_bucket: when
# the block is omitted from config, the server-side value is recorded in
# state and Terraform does not try to manage it. Refresh will pick up the
# new server-side value, but `terraform plan` will propose no changes.

set -euo pipefail

bucket_name=$(terraform output -raw bucket_name)
if [[ -z "$bucket_name" ]]; then
    echo "Could not read 'bucket_name' output from Terraform." >&2
    exit 1
fi

# Default GCS soft-delete retention is 7d (604800s). Bump it to 30d to
# create a visible drift. Valid range is 7d-90d (or 0 to disable).
echo "Setting soft-delete retention to 30d on bucket: gs://$bucket_name"

gcloud storage buckets update "gs://$bucket_name" \
    --soft-delete-duration=30d >/dev/null

echo "Current soft-delete policy:"
gcloud storage buckets describe "gs://$bucket_name" \
    --format='value(soft_delete_policy)'
