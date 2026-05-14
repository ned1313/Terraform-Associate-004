# Azure Import Demo

This directory mirrors the `aws/` import example for Microsoft Azure. The
helper scripts create a resource group and a storage account out-of-band
(using only the Azure CLI), and the Terraform configuration in `main.tf` is
the target state that you will import those resources into.

A storage account is used here because, like an S3 bucket, its name must be
globally unique across all of Azure, making it a realistic stand-in for the
S3 demo.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) 2.50+
- An Azure subscription where you have **Contributor** (or equivalent) rights
  on the subscription or on the target resource group scope.

## Authenticating

The `azurerm` provider supports several authentication methods. The simplest
for an interactive demo is Azure CLI auth:

```bash
az login
az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
```

Terraform will automatically pick up the credentials cached by `az login`.

For non-interactive scenarios (CI, automation) see the provider docs for
service principal and managed identity options:
<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli>

> **Note:** The `azurerm` provider in this configuration does not pin a
> `subscription_id`. It will use whichever subscription `az account show`
> reports as active, or the value of `ARM_SUBSCRIPTION_ID` if set.

## 1. Create the resources out-of-band

Run **one** of the helper scripts. Both create a resource group plus a
uniquely-named storage account and print the resource group name and the
storage account name to stdout.

### PowerShell

```powershell
./create-storage.ps1
# tf-import-demo-rg
# tfimportdemoa1b2c3d4
```

### Bash

```bash
./create-storage.sh
# tf-import-demo-rg
# tfimportdemoa1b2c3d4
```

Both scripts accept `-p` / `-Prefix`, `-g` / `-ResourceGroup`,
`-l` / `-Location`, and `-s` / `-Subscription` arguments. See the script
headers for details.

## 2. Update `main.tf`

Replace the `name` value on the `azurerm_resource_group.logs` and
`azurerm_storage_account.logs` resources with the values printed by the
script in step 1. The location should match what the script used.

## 3. Import the resources

The configuration ships with conventional `resource` blocks (rather than
`import` blocks) so it matches the AWS example. You can either:

- Add `import` blocks (Terraform 1.5+) referencing the Azure resource IDs:

  ```hcl
  import {
    to = azurerm_resource_group.logs
    id = "/subscriptions/<SUB_ID>/resourceGroups/tf-import-demo-rg"
  }

  import {
    to = azurerm_storage_account.logs
    id = "/subscriptions/<SUB_ID>/resourceGroups/tf-import-demo-rg/providers/Microsoft.Storage/storageAccounts/<ACCOUNT_NAME>"
  }
  ```

  Then run:

  ```bash
  terraform init
  terraform plan -generate-config-out=generated.tf
  terraform apply
  ```

- Or use the imperative `terraform import` command:

  ```bash
  terraform init
  terraform import azurerm_resource_group.logs \
    "/subscriptions/<SUB_ID>/resourceGroups/tf-import-demo-rg"
  terraform import azurerm_storage_account.logs \
    "/subscriptions/<SUB_ID>/resourceGroups/tf-import-demo-rg/providers/Microsoft.Storage/storageAccounts/<ACCOUNT_NAME>"
  ```

You can find `<SUB_ID>` with `az account show --query id -o tsv`.

## 4. Clean up

```bash
terraform destroy
```

Or, if you abandoned the import, delete the resource group directly:

```bash
az group delete --name tf-import-demo-rg --yes --no-wait
```
