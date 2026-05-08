# GCP Pet Registry Example

This is the Google Cloud equivalent of the `m6_complete` configuration from the
**Terraform Configuration for Terraform Associate 004** Pluralsight course.
It demonstrates every configuration feature covered in the course using
minimal-cost GCP services (VPC, firewall, and Cloud Storage).

## Features demonstrated

- Resource and data source blocks (`google_project`, `google_client_config`)
- Input variables, local values, and outputs
- Functions and expressions, including a ternary (`var.environment == "prod" ? ... : ...`)
- String interpolation and template directives (`%{ for } ... %{ endfor }`)
- `count` (cats) and `for_each` (dogs, firewall allow rules)
- `depends_on` meta-argument (dogs depend on cats)
- Dynamic blocks (firewall `allow`, archive `source`)
- Variable validation (`environment`, `subnet_cidr`, `separator`)
- Preconditions and postconditions (cat name length, dog object suffix)
- Sensitive input and output values (`foster_parents`)

## Resources created

| Service    | Resource                                                        | Purpose                                   |
|------------|-----------------------------------------------------------------|-------------------------------------------|
| Networking | `google_compute_network`, `google_compute_subnetwork`, `google_compute_firewall` | Base network + dynamic firewall rules   |
| Storage    | `google_storage_bucket`, `google_storage_bucket_object` (many)  | Registry entries, reports, zip archive    |

All resources are either free or covered by GCP's Always Free tier for small
test workloads. A custom-mode VPC with a single subnet is free; a handful of
small Standard-class objects in a regional bucket is essentially free. Remember
to run `terraform destroy` when you are finished.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- A GCP account with an active **billing account** (required even for Always Free resources)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated

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

## Authentication

This configuration uses Application Default Credentials (ADC). Any of the
following will work:

```powershell
# Option 1: user credentials (recommended for dev)
gcloud auth application-default login
gcloud config set project <project-id>

# Option 2: service account key file
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\key.json"

# Option 3: impersonation via gcloud
gcloud auth application-default login --impersonate-service-account=<sa-email>
```

No credentials are stored in the Terraform configuration.

## Usage

From this directory, first set your project ID in `terraform.tfvars` (or on
the command line), then:

```powershell
terraform init
terraform plan
terraform apply
```

To destroy the resources when finished:

```powershell
terraform destroy
```

Override defaults on the command line if you want:

```powershell
terraform apply -var="project_id=my-proj" -var="environment=prod" -var="region=us-east1"
```

## Variables

| Name             | Description                                            | Type           | Default         |
|------------------|--------------------------------------------------------|----------------|-----------------|
| `project_id`     | GCP project ID to deploy into                          | `string`       | —               |
| `region`         | GCP region for regional resources                      | `string`       | `us-central1`   |
| `environment`    | `dev` or `prod` — drives labeling and naming           | `string`       | `dev`           |
| `subnet_cidr`    | CIDR block for the subnet                              | `string`       | `10.10.0.0/24`  |
| `cat_names`      | List of cat names (uses `count`)                       | `list(string)` | —               |
| `dogs_info`      | Map of dog name → breed (uses `for_each`)              | `map(string)`  | —               |
| `separator`      | Column separator in the pet report                     | `string`       | `" | "`         |
| `foster_parents` | Sensitive map of foster parents → preferred pet type   | `map(string)`  | —               |

## Outputs

| Name             | Description                        | Sensitive |
|------------------|------------------------------------|-----------|
| `project_id`     | GCP project ID                     | no        |
| `project_number` | GCP project number                 | no        |
| `region`         | GCP region used                    | no        |
| `bucket_name`    | Name of the GCS bucket             | no        |
| `cat_objects`    | GCS object names for the cats      | no        |
| `dog_objects`    | GCS object names for the dogs      | no        |
| `foster_parents` | List of foster parent names        | yes       |
