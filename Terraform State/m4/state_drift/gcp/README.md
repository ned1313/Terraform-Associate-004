# GCP State Drift Demo

This directory mirrors the `aws/` state drift example for Google Cloud
Platform. Terraform deploys a Cloud Storage bucket, then a helper script
changes a property on it that Terraform tracks as Optional+Computed but
that the configuration does not manage. The result: refresh records the
change into state, but `terraform plan` shows no actions to perform —
classic state drift, not resource drift.

## Choosing the drifted attribute

The AWS example drifts `request_payer`, which in `aws_s3_bucket` v6 is a
read-only export (its lifecycle is owned by the separate
`aws_s3_bucket_request_payment_configuration` resource).

The cleanest GCP analog is the **soft-delete retention duration** on the
bucket. From the `google_storage_bucket` docs:

> `soft_delete_policy` - (Optional, Computed) The bucket's soft delete
> policy... If the block is not provided, server side value will be kept
> which means removal of block won't generate any terraform change.

So when the block is omitted from config:

- First apply records the server default (7 days = 604800s) into state.
- Changing the retention via `gcloud storage buckets update --soft-delete-duration=...`
  out-of-band updates the server.
- The next `terraform refresh`/`plan` reads the new value into state but
  proposes no changes, because the config does not manage the policy.

This precisely matches the "Objects have changed outside of Terraform"
message and empty plan you see in the AWS example.

> **Note on the `google_storage_bucket` resource:** it has very few truly
> read-only exported attributes (just `self_link` and `url`), neither of
> which is mutable. The Optional+Computed `soft_delete_policy` block is
> the next-best fit and is the one used here.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (`gcloud`)
- A GCP account with billing enabled and permission to create projects or
  use an existing one.

## 1. Set up a GCP project

You can either reuse an existing project or create a new one for the demo.

### Option A — Create a new project

```bash
PROJECT_ID="tf-drift-demo-$(openssl rand -hex 3)"

gcloud projects create "$PROJECT_ID" --name="TF State Drift Demo"

gcloud billing accounts list
gcloud billing projects link "$PROJECT_ID" \
    --billing-account="<BILLING_ACCOUNT_ID>"

gcloud config set project "$PROJECT_ID"
gcloud services enable storage.googleapis.com --project "$PROJECT_ID"
```

### Option B — Use an existing project

```bash
gcloud config set project "<EXISTING_PROJECT_ID>"
gcloud services enable storage.googleapis.com
```

You will need the **Storage Admin** role (`roles/storage.admin`) on the
project, or a custom role that allows bucket create/get/update/delete.

## 2. Authenticate

```bash
gcloud auth login
gcloud auth application-default login
```

`gcloud auth application-default login` writes credentials the Terraform
provider reads automatically.

### Tell the provider which project to use

The configuration in `terraform.tf` does not pin a project. Either:

```bash
export GOOGLE_PROJECT="<PROJECT_ID>"
export GOOGLE_REGION="us-central1"   # optional
```

or uncomment `project` / `region` inside the `provider "google"` block.

## 3. Demonstrating state drift

```bash
terraform init
terraform apply -auto-approve

# Confirm there's no drift yet
terraform plan

# Change the soft-delete retention out-of-band
./drift-bucket.sh
# or
./drift-bucket.ps1

# Refresh-only plan now shows the drift in state
terraform plan -refresh-only
```

You'll see something like:

```
Note: Objects have changed outside of Terraform

  # google_storage_bucket.logs has changed
  ~ resource "google_storage_bucket" "logs" {
        id   = "..."
        name = "tf-state-drift-..."
      ~ soft_delete_policy {
          ~ retention_duration_seconds = 604800 -> 2592000
            # (effective_time unchanged)
        }
        # ...other attributes unchanged
    }

No changes. Your infrastructure matches the configuration.
```

A regular `terraform plan` may also note "Objects have changed outside of
Terraform" but will still report **no actions to perform**, because the
config does not manage `soft_delete_policy`.

## 4. Reconciling state drift

```bash
# Update state to match reality, no changes to GCP
terraform apply -refresh-only
```

## 5. Clean up

```bash
terraform destroy -auto-approve
```

If you created a project just for this demo:

```bash
gcloud projects delete "<PROJECT_ID>"
```
