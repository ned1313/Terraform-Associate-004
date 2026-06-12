# Application – GCP

This configuration deploys a simple web server (Apache on Debian) into the
subnetwork created by the **networking/gcp** configuration. It looks up the
subnet by its self link and derives the VPC network from it.

## Resources created

- `data.google_compute_subnetwork` – looks up the subnet provided by `subnet_id`
- `google_compute_firewall` – allows inbound HTTP (port 80) to `http-server` tagged instances
- `google_compute_instance` – the web server, bootstrapped via `metadata_startup_script`

## Inputs

| Variable        | Description                                                  | Default          |
| --------------- | ------------------------------------------------------------ | ---------------- |
| `subnet_id`     | Subnet self link from the networking configuration (required) | –               |
| `project_id`    | GCP project ID (required)                                    | –                |
| `region`        | GCP region to deploy into                                   | `us-central1`    |
| `zone`          | GCP zone for the instance                                   | `us-central1-a`  |
| `machine_type`  | Machine type for the instance                               | `e2-micro`       |
| `common_labels` | Labels applied to the instance                              | `{}`             |

## Setting up authentication with the gcloud CLI

This configuration uses the same Application Default Credentials as the
networking configuration:

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project taco-wagon-demo
gcloud auth application-default set-quota-project taco-wagon-demo
```

The Compute Engine API must be enabled on the project (see the
**networking/gcp** README):

```bash
gcloud services enable compute.googleapis.com --project=taco-wagon-demo
```

## Deploying

Deploy the **networking/gcp** configuration first, then pass its `subnet_id`
output in here:

```bash
terraform init
terraform apply \
  -var="project_id=taco-wagon-demo" \
  -var="subnet_id=$(cd ../../networking/gcp && terraform output -raw subnet_id)"
```

When the apply finishes, browse to the instance's public IP:

```bash
terraform output -raw instance_public_ip
```
