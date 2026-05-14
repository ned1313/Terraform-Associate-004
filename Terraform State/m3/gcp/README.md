# GCP Import Demo

This directory mirrors the `aws/` import example for Google Cloud Platform.
The helper scripts create a Cloud Storage bucket out-of-band (using only
the `gcloud` CLI), and the Terraform configuration in `main.tf` is the
target state that you will import that bucket into.

A GCS bucket is the direct analog of an S3 bucket: its name must be
globally unique across all of GCP.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (`gcloud`)
- A GCP account with billing enabled and permission to create projects or
  use an existing one.

## 1. Set up a GCP project

You can either reuse an existing project or create a new one for the demo.

### Option A — Create a new project

```bash
# Pick a globally-unique project ID (lowercase letters, digits, hyphens; 6-30 chars).
PROJECT_ID="tf-import-demo-$(openssl rand -hex 3)"

# Create the project. If you belong to an organization, pass --organization=<ORG_ID>
# or --folder=<FOLDER_ID> as required by your org policy.
gcloud projects create "$PROJECT_ID" --name="TF Import Demo"

# Link a billing account (required to create GCS buckets).
gcloud billing accounts list
gcloud billing projects link "$PROJECT_ID" \
    --billing-account="<BILLING_ACCOUNT_ID>"

# Make this the active project.
gcloud config set project "$PROJECT_ID"

# Enable the Cloud Storage API.
gcloud services enable storage.googleapis.com --project "$PROJECT_ID"
```

### Option B — Use an existing project

```bash
gcloud config set project "<EXISTING_PROJECT_ID>"
gcloud services enable storage.googleapis.com
```

You will need the **Storage Admin** role (`roles/storage.admin`) on the
project (or a custom role that allows `storage.buckets.create`,
`storage.buckets.get`, `storage.buckets.delete`).

## 2. Authenticate

The `google` provider supports several authentication methods. For an
interactive demo, Application Default Credentials (ADC) is easiest:

```bash
gcloud auth login
gcloud auth application-default login
```

`gcloud auth application-default login` writes credentials to a file the
Terraform provider can read automatically. No environment variables are
required.

For non-interactive scenarios (CI, automation) you can use a service
account key file pointed at by `GOOGLE_APPLICATION_CREDENTIALS`, or use
workload identity federation. See:
<https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication>

### Tell the provider which project to use

The configuration in `terraform.tf` does not pin a project. Either:

```bash
export GOOGLE_PROJECT="<PROJECT_ID>"
export GOOGLE_REGION="us-central1"   # optional
```

or uncomment and set `project` / `region` inside the `provider "google"`
block in `terraform.tf`.

## 3. Create the bucket out-of-band

Run **one** of the helper scripts. Both create a uniquely-named GCS bucket
and print the bucket name to stdout.

### PowerShell

```powershell
./create-bucket.ps1
# tf-import-demo-a1b2c3d4
```

### Bash

```bash
./create-bucket.sh
# tf-import-demo-a1b2c3d4
```

Both scripts accept `-p` / `-Prefix`, `-l` / `-Location`, and `-P` /
`-Project` arguments. See the script headers for details.

## 4. Update `main.tf`

Replace the `name` value on `google_storage_bucket.logs` with the bucket
name printed by the script in step 3. Make sure `location` matches what
the script used (default: `US`).

## 5. Import the bucket

The configuration ships with a conventional `resource` block (rather than
an `import` block) so it matches the AWS example. You can either:

- Add an `import` block (Terraform 1.5+):

  ```hcl
  import {
    to = google_storage_bucket.logs
    id = "<PROJECT_ID>/<BUCKET_NAME>"
  }
  ```

  Then:

  ```bash
  terraform init
  terraform plan -generate-config-out=generated.tf
  terraform apply
  ```

- Or use the imperative `terraform import` command:

  ```bash
  terraform init
  terraform import google_storage_bucket.logs "<PROJECT_ID>/<BUCKET_NAME>"
  ```

The GCS bucket import ID format is `{{project}}/{{name}}`. See the
provider docs for details:
<https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#import>

## 6. Clean up

```bash
terraform destroy
```

Or, if you abandoned the import, delete the bucket directly:

```bash
gcloud storage rm --recursive "gs://<BUCKET_NAME>"
```

If you created a project just for this demo and no longer need it:

```bash
gcloud projects delete "<PROJECT_ID>"
```
