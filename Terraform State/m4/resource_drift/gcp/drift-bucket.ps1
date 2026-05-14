# Updates the GCS bucket labels out-of-band to simulate resource drift.
# Sets environment=production and adds drift=true.
#
# Note: GCP uses "labels" (lowercase keys/values, restricted character set)
# where AWS and Azure use "tags". The drift concept is the same.

$ErrorActionPreference = 'Stop'

# Get the bucket name from the Terraform outputs.
$bucketName = terraform output -raw bucket_name
if ([string]::IsNullOrWhiteSpace($bucketName)) {
    throw "Could not read 'bucket_name' output from Terraform."
}

Write-Host "Updating labels on bucket: gs://$bucketName"

gcloud storage buckets update "gs://$bucketName" `
    --update-labels=environment=production,drift=true | Out-Null

Write-Host "Labels updated. Current labels:"
gcloud storage buckets describe "gs://$bucketName" --format='value(labels)'
