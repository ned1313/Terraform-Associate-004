# Azure Resource Drift Demo

This directory mirrors the `aws/` resource drift example for Microsoft
Azure. Terraform deploys a tagged resource group, then a helper script
modifies the tags out-of-band via the Azure CLI. Running `terraform plan`
afterwards shows the drift.

A resource group is used here because every Azure resource lives in one
and it supports tags directly. The drift mechanic — changing the tag map
out-of-band — is identical to the S3 example.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) 2.50+
- An Azure subscription where you have **Contributor** rights at the
  subscription scope (or at least permission to create/update/delete
  resource groups).

## Authenticating

The `azurerm` provider supports several authentication methods. For an
interactive demo, Azure CLI auth is simplest:

```bash
az login
az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
```

Terraform will automatically pick up the credentials cached by `az login`.

For non-interactive scenarios (CI, automation) see:
<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli>

> The `azurerm` provider in this configuration does not pin a
> `subscription_id`. It will use whichever subscription `az account show`
> reports as active, or the value of `ARM_SUBSCRIPTION_ID` if set.

## Demonstrating drift

```bash
terraform init
terraform apply -auto-approve

# Confirm there's no drift yet
terraform plan

# Drift the tags out-of-band (use whichever script fits your shell)
./drift-rg.sh
# or
./drift-rg.ps1

# Now plan should show that the tags differ from configuration
terraform plan
```

You'll see Terraform plan to revert `Environment` back to `Development`
and remove the `Drift` tag.

## Reconciling drift

- **Accept the change in Azure (update config):** edit `main.tf` to match
  the new tag values, then `terraform plan` should report no changes.
- **Revert Azure to match config:** simply `terraform apply` again.
- **Refresh state only:** `terraform apply -refresh-only` records the new
  tag values into state without changing anything in Azure.

## Clean up

```bash
terraform destroy -auto-approve
```
