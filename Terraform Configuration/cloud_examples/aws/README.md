# AWS Pet Registry Example

This is the AWS cloud equivalent of the `m6_complete` configuration from the
**Terraform Configuration for Terraform Associate 004** Pluralsight course.
It demonstrates every configuration feature covered in the course using
minimal-cost AWS services (VPC, security groups, S3, and SSM Parameter Store).

## Features demonstrated

- Resource and data source blocks (`aws_region`, `aws_caller_identity`)
- Input variables, local values, and outputs
- Functions and expressions, including a ternary (`var.environment == "prod" ? ... : ...`)
- String interpolation and template directives (`%{ for } ... %{ endfor }`)
- `count` (cats) and `for_each` (dogs, security group ingress rules)
- `depends_on` meta-argument (dogs depend on cats)
- Dynamic blocks (security group ingress, archive source)
- Variable validation (`environment`, `vpc_cidr`, `separator`)
- Preconditions and postconditions (cat name length, dog parameter ARN)
- Sensitive input and output values (`foster_parents`)

## Resources created

| Service    | Resource                                     | Purpose                                   |
|------------|----------------------------------------------|-------------------------------------------|
| Networking | `aws_vpc`, `aws_security_group`              | Base network + dynamic ingress rules      |
| Storage    | `aws_s3_bucket`, `aws_s3_object` (x3)        | Stores rendered reports and a zip archive |
| Compute*   | `aws_ssm_parameter` (cats, dogs, fosters)    | Registry entries (Standard tier is free)  |

\* SSM Parameter Store is used as a lightweight, free stand-in for a compute
workload so the example does not incur EC2 charges.

All resources are either free or covered by the AWS Free Tier for small test
workloads. Remember to run `terraform destroy` when you are finished.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- An AWS account
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  installed and authenticated

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

To destroy the resources when finished:

```powershell
terraform destroy
```

Default values in `terraform.tfvars` will be used automatically. Override
them on the command line if you want:

```powershell
terraform apply -var="environment=prod" -var="region=us-west-2"
```

## Variables

| Name             | Description                                            | Type           | Default       |
|------------------|--------------------------------------------------------|----------------|---------------|
| `region`         | AWS region to deploy into                              | `string`       | `us-east-1`   |
| `environment`    | `dev` or `prod` — drives tagging and naming            | `string`       | `dev`         |
| `vpc_cidr`       | CIDR block for the VPC                                 | `string`       | `10.0.0.0/16` |
| `cat_names`      | List of cat names (uses `count`)                       | `list(string)` | —             |
| `dogs_info`      | Map of dog name → breed (uses `for_each`)              | `map(string)`  | —             |
| `separator`      | Column separator in the pet report                     | `string`       | `" | "`       |
| `foster_parents` | Sensitive map of foster parents → preferred pet type   | `map(string)`  | —             |

## Outputs

| Name             | Description                                | Sensitive |
|------------------|--------------------------------------------|-----------|
| `region`         | AWS region used                            | no        |
| `aws_account_id` | AWS account ID                             | no        |
| `bucket_name`    | Name of the S3 bucket                      | no        |
| `cat_parameters` | SSM parameter names for the cats           | no        |
| `dog_parameters` | SSM parameter names for the dogs           | no        |
| `foster_parents` | List of foster parent names                | yes       |
