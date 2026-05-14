#requires -Version 5.1
<#
.SYNOPSIS
    Creates a Google Cloud Storage bucket with a unique name and returns the
    bucket name.

.DESCRIPTION
    Generates a globally-unique GCS bucket name using a prefix plus a short
    random suffix, creates the bucket in the specified GCP project and
    location using the gcloud CLI, and writes the bucket name to stdout so
    a caller can capture it (e.g. for use in a Terraform `import` block).

.PARAMETER Prefix
    Prefix for the bucket name. Must be DNS-compliant (lowercase letters,
    digits, hyphens). Defaults to "tf-import-demo".

.PARAMETER Location
    GCS location/region in which to create the bucket. Defaults to "US"
    (multi-region).

.PARAMETER Project
    GCP project ID. If omitted, the gcloud active project is used
    (`gcloud config get-value project`).

.EXAMPLE
    PS> ./create-bucket.ps1
    tf-import-demo-a1b2c3d4

.EXAMPLE
    PS> $bucket = ./create-bucket.ps1 -Prefix "my-demo" -Location "us-central1"
#>
[CmdletBinding()]
param(
    [ValidatePattern('^[a-z0-9]([a-z0-9-]{1,30}[a-z0-9])?$')]
    [string]$Prefix = 'tf-import-demo',

    [string]$Location = 'US',

    [string]$Project
)

$ErrorActionPreference = 'Stop'

# Ensure the gcloud CLI is available.
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    throw "gcloud CLI was not found in PATH. Install it from https://cloud.google.com/sdk/docs/install."
}

# Resolve the target project.
if (-not $PSBoundParameters.ContainsKey('Project') -or [string]::IsNullOrWhiteSpace($Project)) {
    $Project = (& gcloud config get-value project 2>$null).Trim()
    if ([string]::IsNullOrWhiteSpace($Project) -or $Project -eq '(unset)') {
        throw "No GCP project specified and no active gcloud project is set. Pass -Project or run 'gcloud config set project <ID>'."
    }
}

# Generate an 8-character lowercase-hex suffix for uniqueness.
$suffix = -join ((1..8) | ForEach-Object {
    '{0:x}' -f (Get-Random -Minimum 0 -Maximum 16)
})
$bucketName = "$Prefix-$suffix"

# GCS bucket names must be 3-63 chars (for non-domain names).
if ($bucketName.Length -gt 63) {
    throw "Generated bucket name '$bucketName' exceeds 63 characters. Use a shorter -Prefix."
}

Write-Verbose "Creating GCS bucket 'gs://$bucketName' in project '$Project' (location: $Location)..."

$createArgs = @(
    'storage', 'buckets', 'create', "gs://$bucketName",
    '--project', $Project,
    '--location', $Location,
    '--uniform-bucket-level-access'
)

$null = & gcloud @createArgs 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create GCS bucket '$bucketName' (gcloud exit code $LASTEXITCODE)."
}

# Emit only the bucket name on stdout so callers can capture it cleanly.
$bucketName
