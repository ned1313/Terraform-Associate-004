# Networking – GCP

This configuration builds the network foundation that the GCP application
configuration deploys into. It creates a custom-mode VPC network and a single
subnetwork.

## Resources created

- `google_compute_network` – custom-mode VPC (no auto-created subnets)
- `google_compute_subnetwork` – the public subnet (`subnet_cidr`)

## Outputs

| Output       | Description                                                 |
| ------------ | ----------------------------------------------------------- |
| `network_id` | ID of the VPC network                                       |
| `subnet_id`  | Self link of the subnet (consumed by the application config) |

## Setting up authentication with the gcloud CLI

The `google` provider authenticates using Application Default Credentials (ADC)
from the gcloud CLI.

1. Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install).
2. Sign in and create Application Default Credentials:

   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

## Creating a project with the required APIs

1. Create a new project (project IDs must be globally unique):

   ```bash
   gcloud projects create taco-wagon-demo --name="Taco Wagon Demo"
   ```

2. Link a billing account (required to create Compute Engine resources):

   ```bash
   gcloud billing accounts list
   gcloud billing projects link taco-wagon-demo \
     --billing-account=<BILLING_ACCOUNT_ID>
   ```

3. Set the project as your active project and quota project:

   ```bash
   gcloud config set project taco-wagon-demo
   gcloud auth application-default set-quota-project taco-wagon-demo
   ```

4. Enable the Compute Engine API (required for networks, subnets, and instances):

   ```bash
   gcloud services enable compute.googleapis.com --project=taco-wagon-demo
   ```

## Deploying

```bash
terraform init
terraform apply \
  -var="project_id=taco-wagon-demo" \
  -var="subnet_cidr=10.0.1.0/24"
```

After the apply completes, capture the `subnet_id` output — the application
configuration needs it:

```bash
terraform output -raw subnet_id
```
