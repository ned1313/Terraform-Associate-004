# Azure Pet Registry – Modules Example

This is the Azure cloud equivalent of the `m3_complete` configuration from the
**Terraform Modules for Terraform Associate 004** Pluralsight course. It
demonstrates the same module-related concepts taught in the course, but uses
free / minimal-cost Azure services instead of the `random` and `local`
providers.

## Course features demonstrated

| Feature                                                  | Where it lives                                                       |
|----------------------------------------------------------|----------------------------------------------------------------------|
| Use of a **local module**                                | `module "pet_report"` -> `./modules/pet_report`                      |
| Use of a **module from the public registry**             | `module "vnet"` -> `Azure/avm-res-network-virtualnetwork/azurerm`    |
| **Upgrading** to a newer module version (m3)             | See [Upgrade scenario](#upgrade-scenario-m2--m3) below               |
| Dealing with **provider version conflicts** on upgrade   | See [Upgrade scenario](#upgrade-scenario-m2--m3) below               |

## Architecture

| Layer       | Resource                                                          | Purpose                                                       |
|-------------|-------------------------------------------------------------------|---------------------------------------------------------------|
| Networking  | `Azure/avm-res-network-virtualnetwork/azurerm` (public registry)  | VNet with a single subnet (no NAT gateway, no public IPs)     |
| Compute*    | `azurerm_storage_table_entity` (one per pet)                      | Lightweight registry entry for each pet                       |
| Storage     | `azurerm_storage_account` + `azurerm_storage_blob` (local module) | Holds the rendered Markdown and JSON pet reports              |

\* Storage Table entities are billed per GB stored and per transaction, so a
handful of pet entries costs effectively nothing while idle. This example
provisions no VMs, no AKS, no App Service, and no Public IPs. The Standard
LRS storage account is the cheapest redundancy tier available.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.9.0
- An Azure subscription
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed and authenticated

## Authentication

This configuration uses the default Azure credential chain via the `azurerm`
provider. The simplest path is the Azure CLI:

```powershell
# Sign in interactively
az login

# Pick the subscription the deployment should target
az account set --subscription "<subscription-name-or-id>"

# Optional: pin the subscription explicitly for Terraform
$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)
```

Service-principal authentication via environment variables also works:

```powershell
$env:ARM_TENANT_ID       = "<tenant-id>"
$env:ARM_SUBSCRIPTION_ID = "<subscription-id>"
$env:ARM_CLIENT_ID       = "<sp-app-id>"
$env:ARM_CLIENT_SECRET   = "<sp-secret>"
```

No credentials are stored in the Terraform configuration. The `subscription_id`
input variable defaults to an empty string and falls through to the
`ARM_SUBSCRIPTION_ID` env var / Azure CLI active subscription.

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
terraform apply -var="pet_type=cat" -var="quantity=5" -var="location=westus2"
```

After `apply`, the rendered reports are uploaded to the blob container:

```powershell
$sa  = terraform output -raw storage_account_name
$rg  = terraform output -raw resource_group_name
$cnt = terraform output -raw container_name
$md  = terraform output -raw markdown_report_blob

# List the rendered reports
az storage blob list `
  --account-name $sa `
  --container-name $cnt `
  --auth-mode login `
  --output table

# Print the Markdown report to the console
az storage blob download `
  --account-name $sa `
  --container-name $cnt `
  --name $md `
  --auth-mode login `
  --file -
```

Or open the blob container directly in the Azure Portal under the storage
account named by `terraform output -raw storage_account_name`.

## Upgrade scenario (m2 → m3)

The course module 2 finishes with the public registry module pinned to an
older version, and module 3 demonstrates upgrading it. The Azure VNet AVM
module currently requires `azurerm ~> 4.0`, so a typical m2 baseline that
pinned the provider to `~> 3.0` will hit a provider conflict the moment the
network module is introduced or upgraded. To replay that flow on this Azure
example:

1. **Start at the "m2" state.** Edit `terraform.tf` to pin the provider to
   the previous major and (optionally) pin the module to an older 0.x line:

   ```hcl
   # terraform.tf
   azurerm = {
     source  = "hashicorp/azurerm"
     version = "~> 3.0"
   }

   # main.tf
   module "vnet" {
     source  = "Azure/avm-res-network-virtualnetwork/azurerm"
     version = "~> 0.8.0"
     # ...
   }
   ```

  Reverting to the older version of the `azurerm` provider also requires some code updates.
  
  In the `vnet` module, comment out the `parent_id` argument and replace it with the `resource_group_name` argument.

  ```hcl
  #parent_id        = azurerm_resource_group.this.id
  resource_group_name = azurerm_resource_group.this.name
  ```

  In the `azurerm_storage_container` resource, comment out the `storage_account_id` argument and replace it with the `storage_account_name` argument.

  ```hcl
  #storage_account_id    = azurerm_storage_account.reports.id
  storage_account_name = azurerm_storage_account.reports.name
  ```

   Run `terraform init` and `terraform apply`. This is the working m2 baseline.

2. **Upgrade the module (the m3 step).** Bump the VNet module version
   constraint to `~> 0.17` but **leave the azurerm provider pinned to `~> 3.0`**
   for a moment, then run:

   ```powershell
   terraform init -upgrade
   ```

   Terraform will fail with a provider version conflict similar to:

   ```
   Error: Failed to query available provider packages

   Could not retrieve the list of available versions for provider
   hashicorp/azurerm: no available releases match the given constraints
   ~> 3.0, ~> 4.0

   ...module.vnet (Azure/avm-res-network-virtualnetwork/azurerm) requires
   hashicorp/azurerm ~> 4.0, but the root module constrains it to ~> 3.0.
   ```

   This is the exact provider-conflict-during-module-upgrade scenario covered
   in the course: a newer module release ships with a tightened provider
   constraint that the root module has not yet adopted.

3. **Resolve the conflict.** Relax the azurerm provider constraint in
   `terraform.tf` to `~> 4.0` (the version checked into this example) and
   run `terraform init -upgrade` again.
   
   Undo the code changes made in step 1 by deleting the added argument and uncommenting the correct argument. The upgrade now succeeds and `terraform apply` proceeds normally.

The configuration as committed in this folder represents the **post-upgrade
("m3") state**: VNet module `~> 0.17` paired with azurerm provider `~> 4.0`.

> **Why this is a 0.x → 0.x bump rather than a major-version bump:** the
> Azure Verified Module program publishes resource modules under a 0.y.z
> SemVer track. Per the AVM versioning notice, every minor (`0.y`) release
> is treated as a potentially breaking change, so bumping `~> 0.8.0` to
> `~> 0.17` carries the same risk profile as a major-version bump on a
> stable module.

## Variables

| Name              | Description                                                            | Type     | Default        |
|-------------------|------------------------------------------------------------------------|----------|----------------|
| `location`        | Azure region to deploy into                                            | `string` | `eastus`       |
| `subscription_id` | Subscription ID; empty string falls back to env / az CLI active sub    | `string` | `""`           |
| `name_prefix`     | Prefix applied to created resource names                               | `string` | `pet-registry` |
| `pet_type`        | The type of pet to register (e.g. `dog`, `cat`)                        | `string` | `dog`          |
| `quantity`        | Number of pets to register (1-20)                                      | `number` | `3`            |

## Outputs

| Name                    | Description                                              |
|-------------------------|----------------------------------------------------------|
| `resource_group_name`   | Name of the resource group holding all resources         |
| `vnet_id`               | ID of the VNet created by the registry module            |
| `subnet_ids`            | IDs of the subnets created by the registry module        |
| `storage_account_name`  | Name of the Storage Account                              |
| `container_name`        | Name of the reports blob container                       |
| `pets`                  | List of registered pet objects                           |
| `markdown_report_blob`  | Blob name of the Markdown report                         |
| `json_report_blob`      | Blob name of the JSON report                             |
