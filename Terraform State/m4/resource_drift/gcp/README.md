# GCP Resource Drift Demo

This directory mirrors the `aws/` resource drift example for Google Cloud
Platform. Terraform deploys a Cloud Storage bucket with a label, then a
helper script modifies the labels out-of-band via the `gcloud` CLI. Running
`terraform plan` afterwards shows the drift.

> **Tags vs. labels:** AWS and Azure call the key/value metadata on
> resources "tags". GCP calls it "labels" (lowercase keys, restricted
> character set). GCP also has a separate concept literally called "tags"
> used for IAM conditions and firewall policies — that is **not** what
> this demo uses.

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
PROJECT_ID="tf-drift-demo-$(openssl rand -hex 3)"

# Create the project. If you belong to an organization, pass --organization=<ORG_ID>
# or --folder=<FOLDER_ID> as required by your org policy.
gcloud projects create "$PROJECT_ID" --name="TF Drift Demo"

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
`storage.buckets.get`, `storage.buckets.update`, `storage.buckets.delete`).

## 2. Authenticate

For an interactive demo, Application Default Credentials (ADC) is easiest:

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

## 3. Demonstrating drift

```bash
terraform init
terraform apply -auto-approve

# Confirm there's no drift yet
terraform plan

# Drift the labels out-of-band (use whichever script fits your shell)
./drift-bucket.sh
# or
./drift-bucket.ps1

# Now plan should show that the labels differ from configuration
terraform plan
```

You'll see Terraform plan to revert `environment` back to `development`
and remove the `drift` label.

## 4. Reconciling drift

- **Accept the change in GCP (update config):** edit `main.tf` to match
  the new label values, then `terraform plan` should report no changes.
- **Revert GCP to match config:** simply `terraform apply` again.
- **Refresh state only:** `terraform apply -refresh-only` records the new
  label values into state without changing anything in GCP.

## 5. Clean up

```bash
terraform destroy -auto-approve
```

If you created a project just for this demo and no longer need it:

```bash
gcloud projects delete "<PROJECT_ID>"
```
