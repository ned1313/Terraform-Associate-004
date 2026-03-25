# Azure Resource Group Example

This configuration provisions a single Azure resource group using the AzureRM provider.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.12.0
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed

## Authentication

This configuration uses Azure CLI authentication. Log in before running Terraform:

```bash
az login
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
| `resource_group_name` | Name of the resource group | `string` | — |
| `location` | Azure region for resources | `string` | `eastus` |

## Outputs

| Name | Description |
|------|-------------|
| `resource_group_id` | ID of the resource group created |
