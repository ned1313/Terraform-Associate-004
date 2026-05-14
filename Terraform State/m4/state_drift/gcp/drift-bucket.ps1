# Changes the GCS bucket soft-delete retention duration out-of-band to
# simulate state drift on an attribute that Terraform tracks as
# Optional+Computed but that this configuration does not manage.
#
# `soft_delete_policy` is Optional+Computed on google_storage_bucket: when
# the block is omitted from config, the server-side value is recorded in
# state and Terraform does not try to manage it. Refresh will pick up the
# new server-side value, but `terraform plan` will propose no changes.

$ErrorActionPreference = 'Stop'

$bucketName = terraform output -raw bucket_name
if ([string]::IsNullOrWhiteSpace($bucketName)) {
    throw "Could not read 'bucket_name' output from Terraform."
}

# Default GCS soft-delete retention is 7d (604800s). Bump it to 30d to
# create a visible drift. Valid range is 7d-90d (or 0 to disable).
Write-Host "Setting soft-delete retention to 30d on bucket: gs://$bucketName"

gcloud storage buckets update "gs://$bucketName" `
    --soft-delete-duration=30d | Out-Null

Write-Host "Current soft-delete policy:"
gcloud storage buckets describe "gs://$bucketName" `
    --format='value(soft_delete_policy)'
