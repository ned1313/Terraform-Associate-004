# ---------------------------------------------------------------------------
# Resource group - the container everything else lives in.
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  name     = "${var.name_prefix}-rg"
  location = var.location

  tags = {
    Project   = "pet-registry"
    ManagedBy = "Terraform"
    Course    = "Terraform Modules for Terraform Associate 004"
    PetType   = var.pet_type
  }
}

# ---------------------------------------------------------------------------
# Networking - public registry module (Azure Verified Module for VNet)
#
# This is the "module from the public registry" demonstration. The version
# constraint is intentionally relaxed (~> 0.17) so the module can be upgraded
# inside the same minor-major track. See the README for the m2 -> m3 upgrade
# story (which also forces an azurerm provider bump).
# ---------------------------------------------------------------------------

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.17"

  name             = "${var.name_prefix}-vnet"
  location         = azurerm_resource_group.this.location
  parent_id        = azurerm_resource_group.this.id
  address_space    = ["10.0.0.0/16"]
  enable_telemetry = false

  subnets = {
    pets = {
      name             = "${var.name_prefix}-subnet"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

# ---------------------------------------------------------------------------
# Storage - one storage account holds both the rendered reports (blob
# container) and the lightweight per-pet registry entries (table). Standard
# LRS is the cheapest redundancy option and table/blob storage is billed per
# GB used, so an idle deployment costs effectively nothing.
# ---------------------------------------------------------------------------

resource "random_string" "sa_suffix" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  # Storage account names must be 3-24 lowercase alphanumeric characters.
  storage_account_name = substr(
    "${replace(var.name_prefix, "-", "")}${random_string.sa_suffix.result}",
    0,
    24,
  )
}

resource "azurerm_storage_account" "reports" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "reports" {
  name                  = "reports"
  storage_account_id    = azurerm_storage_account.reports.id
  container_access_type = "private"
}

# ---------------------------------------------------------------------------
# "Compute" - one storage table entity per pet. Storage tables are billed per
# GB and per transaction, so a handful of entries costs effectively zero.
# This is the Azure equivalent of the AWS example's SSM parameters.
# ---------------------------------------------------------------------------

resource "random_pet" "pets" {
  count  = var.quantity
  prefix = var.pet_type
  length = 2
}

locals {
  pets = [
    for i in range(var.quantity) : {
      name            = random_pet.pets[i].id
      type            = var.pet_type
      id              = format("%s-%03d", var.pet_type, i + 1)
      age             = (i + 1) * 2
      adoption_status = i % 2 == 0 ? "available" : "pending"
    }
  ]
}

resource "azurerm_storage_table" "pets" {
  name                 = "petregistry"
  storage_account_name = azurerm_storage_account.reports.name
}

resource "azurerm_storage_table_entity" "pets" {
  count = var.quantity

  storage_table_id = azurerm_storage_table.pets.id
  partition_key    = var.pet_type
  row_key          = local.pets[count.index].id

  entity = {
    name            = local.pets[count.index].name
    type            = local.pets[count.index].type
    id              = local.pets[count.index].id
    age             = tostring(local.pets[count.index].age)
    adoption_status = local.pets[count.index].adoption_status
  }
}

# ---------------------------------------------------------------------------
# Local module - renders the Markdown + JSON pet reports and uploads them to
# the blob container.
# ---------------------------------------------------------------------------

module "pet_report" {
  source = "./modules/pet_report"

  pet_type             = var.pet_type
  storage_account_name = azurerm_storage_account.reports.name
  container_name       = azurerm_storage_container.reports.name
  key_prefix           = "reports"

  pets = local.pets
}
