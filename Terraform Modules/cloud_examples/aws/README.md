# AWS Pet Registry – Modules Example

This is the AWS cloud equivalent of the `m3_complete` configuration from the
**Terraform Modules for Terraform Associate 004** Pluralsight course. It
demonstrates the same module-related concepts taught in the course, but uses
free / minimal-cost AWS services instead of the `random` and `local`
providers.

## Course features demonstrated

| Feature                                                  | Where it lives                                         |
|----------------------------------------------------------|--------------------------------------------------------|
| Use of a **local module**                                | `module "pet_report"` -> `./modules/pet_report`        |
| Use of a **module from the public registry**             | `module "vpc"` -> `terraform-aws-modules/vpc/aws`      |
| **Upgrading** to a newer module version (m3)             | See [Upgrade scenario](#upgrade-scenario-m2--m3) below |
| Dealing with **provider version conflicts** on upgrade   | See [Upgrade scenario](#upgrade-scenario-m2--m3) below |

## Architecture

| Layer       | Resource                                              | Purpose                                              |
|-------------|-------------------------------------------------------|------------------------------------------------------|
| Networking  | `terraform-aws-modules/vpc/aws` (public registry)     | VPC + public subnets across two AZs                  |
| Compute*    | `aws_ssm_parameter` (one per pet)                     | Lightweight registry entry for each pet (free tier)  |
| Storage     | `aws_s3_bucket` + `aws_s3_object` (via local module)  | Holds the rendered Markdown and JSON pet reports     |

\* SSM Parameter Store *Standard* parameters are free, so this example does not
provision any EC2 instances. NAT gateways are disabled in the VPC for the same
reason. Everything created here fits comfortably inside the AWS Free Tier for
short-lived test workloads.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- An AWS account
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and authenticated

## Authentication

This configuration uses the default AWS credential chain. Any of the following
will work:

```powershell
# Option 1: AWS CLI profile
aws configure

# Option 2: environment variables
$env:AWS_ACCESS_KEY_ID     = "AKIA..."
$env:AWS_SECRET_ACCESS_KEY = "..."
$env:AWS_REGION            = "us-east-1"

# Option 3: SSO
aws sso login --profile my-profile
$env:AWS_PROFILE = "my-profile"
```

No credentials are stored in the Terraform configuration.

## Usage

From this directory:

```powershell
terraform init
terraform plan
terraform apply
```

To remove the resources when finished:

```powershell
terraform destroy
```

You can override any default on the command line:

```powershell
terraform apply -var="pet_type=cat" -var="quantity=5" -var="region=us-west-2"
```

After `apply`, the rendered reports are uploaded to S3:

```powershell
aws s3 ls "s3://$(terraform output -raw bucket_name)/reports/"
aws s3 cp "s3://$(terraform output -raw bucket_name)/$(terraform output -raw markdown_report_object)" -
```

## Upgrade scenario (m2 → m3)

The course module 2 finishes with the public registry module pinned to a
specific older version, and module 3 demonstrates upgrading it. To replay that
flow on this AWS example:

1. **Start at the "m2" state.** Edit `main.tf` and change the VPC module block
   to pin to the previous major version, and edit `terraform.tf` to match the
   AWS provider that version requires:

   ```hcl
   # main.tf
   module "vpc" {
     source  = "terraform-aws-modules/vpc/aws"
     version = "~> 5.0"
     # ...
   }

   # terraform.tf
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.0"
   }
   ```

   Run `terraform init` and `terraform apply`. This is the working m2 baseline.

2. **Upgrade the module (the m3 step).** Change the VPC module version
   constraint to `~> 6.0` but **leave the AWS provider pinned to `~> 5.0`** for
   a moment, then run:

   ```powershell
   terraform init -upgrade
   ```

   Terraform will fail with a provider version conflict similar to:

   ```
   Error: Failed to query available provider packages
   ...module.vpc requires hashicorp/aws >= 6.28, but the root module
   constrains it to ~> 5.0.
   ```

   This is the exact provider-conflict-during-module-upgrade scenario covered
   in the course.

3. **Resolve the conflict.** Relax the AWS provider constraint in
   `terraform.tf` to `~> 6.0` (the version checked into this example) and run
   `terraform init -upgrade` again. The upgrade now succeeds and
   `terraform apply` proceeds normally.

The configuration as committed in this folder represents the **post-upgrade
("m3") state**: VPC module `~> 6.0` paired with AWS provider `~> 6.0`.

## Variables

| Name          | Description                                        | Type     | Default        |
|---------------|----------------------------------------------------|----------|----------------|
| `region`      | AWS region to deploy into                          | `string` | `us-east-1`    |
| `name_prefix` | Prefix applied to created resource names           | `string` | `pet-registry` |
| `pet_type`    | The type of pet to register (e.g. `dog`, `cat`)    | `string` | `dog`          |
| `quantity`    | Number of pets to register (1-20)                  | `number` | `3`            |

## Outputs

| Name                     | Description                                    |
|--------------------------|------------------------------------------------|
| `vpc_id`                 | ID of the VPC created by the registry module   |
| `public_subnet_ids`      | Public subnet IDs                              |
| `bucket_name`            | Name of the S3 reports bucket                  |
| `pets`                   | List of registered pet objects                 |
| `markdown_report_object` | S3 key of the Markdown report                  |
| `json_report_object`     | S3 key of the JSON report                      |
