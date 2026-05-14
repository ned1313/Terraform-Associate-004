# Azure State Drift Demo

This directory mirrors the `aws/` state drift example for Microsoft Azure.
Terraform deploys a storage account, then a helper script changes a
property on it that Terraform exposes as a **read-only/computed attribute**
but does not manage as a config input. The result: refresh records the
change into state, but `terraform plan` shows no actions to perform —
classic state drift, not resource drift.

## Choosing the drifted attribute

The AWS example drifts `request_payer`, which in `aws_s3_bucket` v6 is a
read-only export (its lifecycle is owned by the separate
`aws_s3_bucket_request_payment_configuration` resource).

The cleanest Azure analog is **rotating the storage account's
`primary_access_key`**:

- `primary_access_key` is listed in the `azurerm_storage_account`
  Attributes Reference, not the Arguments Reference — it is a
  **computed-only exported attribute**, never a config input.
- Rotating the key (`az storage account keys renew`) is a real operational
  task that admins routinely perform out-of-band.
- On the next `terraform refresh`/`plan`, Terraform reads the new key and
  updates state, but proposes no changes because nothing in the config
  references the key as an input.

This precisely matches the "Objects have changed outside of Terraform"
message and empty plan you see in the AWS example.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) 2.50+
- An Azure subscription where you have **Contributor** rights (or at least
  permission to create resource groups and storage accounts and to
  regenerate storage account keys).

## Authenticating

```bash
az login
az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
```

The `azurerm` provider will pick up the cached `az login` credentials
automatically. The configuration does not pin a `subscription_id`; it
uses whichever subscription `az account show` reports as active.

## Demonstrating state drift

```bash
terraform init
terraform apply -auto-approve

# Confirm there's no drift yet
terraform plan

# Rotate the primary access key out-of-band
./drift-account.sh
# or
./drift-account.ps1

# Refresh-only plan now shows the drift in state
terraform plan -refresh-only
```

The `-refresh-only` plan reports something like:

```
Note: Objects have changed outside of Terraform

  # azurerm_storage_account.logs has changed
  ~ resource "azurerm_storage_account" "logs" {
        id                          = "..."
      ~ primary_access_key          = (sensitive value)
      ~ primary_connection_string   = (sensitive value)
      ~ primary_blob_connection_string = (sensitive value)
        # ...other attributes unchanged
    }

No changes. Your infrastructure matches the configuration.
```

A regular `terraform plan` may also note "Objects have changed outside of
Terraform" but will still report **no actions to perform**, because no
configured argument has drifted — only computed exports.

## Reconciling state drift

```bash
# Update state to match reality, no changes to Azure
terraform apply -refresh-only
```

## Clean up

```bash
terraform destroy -auto-approve
```
