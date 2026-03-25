# AWS S3 Bucket Example

This configuration provisions an S3 bucket and a bucket object using the AWS provider.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.12.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed

## Authentication

This configuration uses the default AWS credential chain. Configure credentials via the AWS CLI:

```bash
aws configure
```

## Usage

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
| `bucket_name_prefix` | Prefix name of the S3 bucket | `string` | — |
| `object_key` | Key for the S3 bucket object | `string` | — |
| `object_content` | Content of the S3 bucket object | `string` | `Hello, Terraform!` |
| `region` | AWS region for resources | `string` | `us-east-1` |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | ID of the S3 bucket created |
| `object_key` | Key of the S3 object created |
