# Azure Pet Registry Example

This is the Azure cloud equivalent of the `m6_complete` configuration from the
**Terraform Configuration for Terraform Associate 004** Pluralsight course.
It demonstrates every configuration feature covered in the course using
minimal-cost Azure services (Virtual Network, Network Security Group, and
Azure Storage).

## Features demonstrated

- Resource and data source blocks (`azurerm_subscription`, `azurerm_client_config`)
- Input variables, local values, and outputs
- Functions and expressions, including a ternary (`var.environment == "prod" ? ... : ...`)
- String interpolation and template directives (`%{ for } ... %{ endfor }`)
- `count` (cats) and `for_each` (dogs, NSG rules)
- `depends_on` meta-argument (dogs depend on cats)
- Dynamic blocks (NSG `security_rule`, archive `source`)
- Variable validation (`environment`, `vnet_cidr`, `separator`)
- Preconditions and postconditions (cat name length, dog blob suffix)
- Sensitive input and output values (`foster_parents`)

## Resources created

| Service    | Resource                                               | Purpose                                  |
|------------|--------------------------------------------------------|------------------------------------------|
| Core       | `azurerm_resource_group`                               | Container for all resources              |
| Networking | `azurerm_virtual_network`, `azurerm_network_security_group` | Base network + dynamic `security_rule` |
| Storage    | `azurerm_storage_account`, `azurerm_storage_container` (x2), `azurerm_storage_blob` (many) | Registry entries, reports, and zip archive |

All resources are either free or essentially free for small test workloads.
A Standard LRS storage account with a handful of small blobs costs a few
cents per month; the VNet and NSG are free. Remember to run
`terraform destroy` when you are finished.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- An Azure subscription
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed
  and authenticated

## Authentication

This configuration uses the default Azure credential chain. Any of the
following will work:

```powershell
# Option 1: interactive login (recommended for dev)
az login
az account set --subscription "<subscription-id-or-name>"
$env:ARM_SUBSCRIPTION_ID = "..." # Required for v4 of the provider

# Option 2: service principal via environment variables
$env:ARM_CLIENT_ID       = "..."
$env:ARM_CLIENT_SECRET   = "..."
$env:ARM_TENANT_ID       = "..."
$env:ARM_SUBSCRIPTION_ID = "..."

# Option 3: managed identity (on an Azure VM / Cloud Shell)
$env:ARM_USE_MSI         = "true"
$env:ARM_SUBSCRIPTION_ID = "..."
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
terraform apply -var="environment=prod" -var="location=westus2"
```

## Variables

| Name             | Description                                            | Type           | Default       |
|------------------|--------------------------------------------------------|----------------|---------------|
| `location`       | Azure region to deploy into                            | `string`       | `eastus`      |
| `environment`    | `dev` or `prod` — drives tagging and naming            | `string`       | `dev`         |
| `vnet_cidr`      | CIDR block for the virtual network                     | `string`       | `10.0.0.0/16` |
| `cat_names`      | List of cat names (uses `count`)                       | `list(string)` | —             |
| `dogs_info`      | Map of dog name → breed (uses `for_each`)              | `map(string)`  | —             |
| `separator`      | Column separator in the pet report                     | `string`       | `" | "`       |
| `foster_parents` | Sensitive map of foster parents → preferred pet type   | `map(string)`  | —             |

## Outputs

| Name                   | Description                              | Sensitive |
|------------------------|------------------------------------------|-----------|
| `location`             | Azure region used                        | no        |
| `subscription_id`      | Azure subscription ID                    | no        |
| `tenant_id`            | Azure AD tenant ID                       | no        |
| `resource_group_name`  | Name of the resource group               | no        |
| `storage_account_name` | Name of the storage account              | no        |
| `cat_blobs`            | Blob names for the cats                  | no        |
| `dog_blobs`            | Blob names for the dogs                  | no        |
| `foster_parents`       | List of foster parent names              | yes       |
