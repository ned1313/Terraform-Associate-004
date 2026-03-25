# Google Cloud Storage Bucket Example

This configuration creates a Google Cloud project, enables the Cloud Storage API, and provisions a Cloud Storage bucket.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.12.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed

## Authentication

This configuration uses Application Default Credentials. Log in via the gcloud CLI:

```bash
gcloud auth application-default login
```

## Usage

Update `testing.tfvars` with your billing account ID and organization ID before running.

Initialize the working directory:

```bash
terraform init
```

Review the execution plan:

```bash
terraform plan -var-file="testing.tfvars"
```

Apply the configuration:

```bash
terraform apply -var-file="testing.tfvars"
```

Destroy the resources when finished:

```bash
terraform destroy -var-file="testing.tfvars"
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `project_name` | Display name for the Google Cloud project | `string` | — |
| `billing_account` | Billing account ID to associate with the project | `string` | — |
| `org_id` | Organization ID for the project | `string` | — |
| `bucket_name_prefix` | Prefix for the Cloud Storage bucket name | `string` | — |
| `region` | Google Cloud region for resources | `string` | `us-central1` |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | ID of the Google Cloud project created |
| `bucket_name` | Name of the Cloud Storage bucket created |
