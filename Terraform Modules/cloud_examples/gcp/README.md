# Pet Registry — GCP Cloud Example

A minimal-cost Google Cloud version of the pet registry example used in the
**Terraform Associate (004) — Modules** course on Pluralsight. It mirrors the
AWS and Azure cloud examples so you can compare the same patterns across all
three providers.

## Course features demonstrated

| Feature | Where it appears |
|---|---|
| Public registry module | `module "vpc"` in [main.tf](main.tf#L9-L26) using `terraform-google-modules/network/google` |
| Local module | `module "pet_report"` in [main.tf](main.tf#L74-L81) sourced from [./modules/pet_report](modules/pet_report) |
| Pinned major version | `version = "~> 18.0"` on the network module, `~> 7.0` on the google provider |
| Module upgrade walkthrough | See [Module upgrade scenario](#module-upgrade-scenario-m2--m3) below |
| Provider version conflict | Triggered intentionally during the upgrade — see same section |

## Architecture

| Layer | Resource | Purpose |
|---|---|---|
| Networking | `module.vpc` (public registry) | Creates a VPC and one regional subnet |
| Records | `google_storage_bucket_object.pets` (one per pet) | Cheapest "key/value" store for pet records — one JSON object per pet |
| Storage | `google_storage_bucket.registry` | Single bucket holding both pet records and the generated reports |
| Reporting | `module.pet_report` (local) | Renders a markdown table and a JSON dump of the pets |

All resources are pay-as-you-go and either free-tier eligible or cents per
month at this scale (one tiny VPC, one regional subnet, one Standard GCS
bucket with a handful of small objects).

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) **>= 1.6.0**
- [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- A GCP project with billing enabled
- The Compute Engine API enabled on that project (`gcloud services enable compute.googleapis.com`)

## Create a new GCP project

If you do not already have a project to use, create one with the gcloud CLI.
Project IDs must be globally unique, 6–30 characters, lowercase letters,
digits, and hyphens.

```powershell
# Sign in and pick an account
gcloud auth login

# Find your billing account ID (format: XXXXXX-XXXXXX-XXXXXX)
gcloud billing accounts list

# Create the project (replace <project-id> and <project-name>)
gcloud projects create <project-id> --name="<project-name>"

# Set it as the active project for gcloud
gcloud config set project <project-id>

# Link billing (required before enabling APIs)
gcloud billing projects link <project-id> --billing-account=<billing-account-id>

# Enable the APIs used by this example
gcloud services enable compute.googleapis.com storage.googleapis.com --project <project-id>
```

> **Cleanup tip:** when finished with the example you can delete the whole
> project to guarantee no lingering charges: `gcloud projects delete <project-id>`.

If you already have a project, just enable the required APIs on it:

```powershell
gcloud services enable compute.googleapis.com storage.googleapis.com --project <project-id>
```

## Authentication (PowerShell)

```powershell
# Sign in and set Application Default Credentials (ADC) for Terraform
gcloud auth login
gcloud auth application-default login

# Tell Terraform which project to use (either via the variable or env var)
$env:TF_VAR_project = "my-gcp-project-id"
```

## Usage

```powershell
cd "Terraform Modules\cloud_examples\gcp"

terraform init
terraform plan
terraform apply -auto-approve

# Inspect the generated reports
$bucket = terraform output -raw bucket_name
gcloud storage cat "gs://$bucket/reports/pet_report.md"
gcloud storage cat "gs://$bucket/reports/pet_report.json"

terraform destroy -auto-approve
```

## Module upgrade scenario (m2 → m3)

To simulate the module upgrade issue, you'll need to downgrade the google provider version and network module version.

Update the code as follows:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"
}
```

Then run initialize Terraform to downgrade the provider and module versions:

```bash
terraform init -upgrade
```

### Provoking the provider conflict

If you bump **only** the module without also bumping the google provider —
i.e. keep `google = "~> 5.0"` and change the module to `"~> 18.0"` — `terraform
init` fails because the v18 `subnets` submodule requires a much newer google
provider:

```text
Error: Failed to query available provider packages

Could not retrieve the list of available versions for provider hashicorp/google:
no available releases match the given constraints ~> 5.0, >= 6.28.0, < 8.0.0

module.vpc.module.subnets[0] requires hashicorp/google >= 6.28.0, < 8.0.0
```

Resolve the conflict by upgrading the root provider constraint to `~> 7.0` so
that all three constraints (root, `module.vpc`, `module.vpc.module.subnets`)
intersect on a single available release. Then run `terraform init -upgrade`
to download the new provider and module versions.

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `project` | GCP project ID | `string` | — (required) |
| `region` | GCP region for regional resources | `string` | `"us-central1"` |
| `zone` | GCP zone for zonal resources | `string` | `"us-central1-a"` |
| `name_prefix` | Prefix used when naming resources | `string` | `"pet-registry"` |
| `pet_type` | Pet type (used in `random_pet` and the report header) | `string` | `"dog"` |
| `quantity` | Number of pets to register (1–20) | `number` | `3` |

## Outputs

| Name | Description |
|------|-------------|
| `network_name` | Name of the VPC network |
| `subnet_names` | Names of the subnets created by the public module |
| `bucket_name` | Name of the GCS bucket holding records and reports |
| `pets` | List of generated pets with all attributes |
| `markdown_report_object` | GCS object name of the markdown report |
| `json_report_object` | GCS object name of the JSON report |
