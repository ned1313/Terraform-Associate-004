provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Local values (including a ternary expression)
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.environment}-pet-registry"

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = var.environment == "prod" ? "1000" : "2000"
  }

  # Dynamic block source: NSG rules to allow web traffic.
  nsg_rules = {
    AllowHTTP = {
      priority = 100
      port     = "80"
    }
    AllowHTTPS = {
      priority = 110
      port     = "443"
    }
  }
}

# ---------------------------------------------------------------------------
# Random suffix (storage account names must be globally unique)
# ---------------------------------------------------------------------------

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# ---------------------------------------------------------------------------
# Resource group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------
# Networking: VNet + NSG with a dynamic security_rule block
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "main" {
  name                = "${local.name_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "pets" {
  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name                       = security_rule.key
      description                = "Allow ${upper(security_rule.key)} traffic"
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  }
}

# ---------------------------------------------------------------------------
# Storage: account and containers that hold registry entries and reports
# ---------------------------------------------------------------------------

resource "azurerm_storage_account" "pet_registry" {
  name                     = "petreg${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = false
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "pets" {
  name                  = "pets"
  storage_account_id    = azurerm_storage_account.pet_registry.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "reports" {
  name                  = "reports"
  storage_account_id    = azurerm_storage_account.pet_registry.id
  container_access_type = "private"
}

# ---------------------------------------------------------------------------
# "Compute-like" registry entries: blobs for cats (count) and dogs (for_each)
# ---------------------------------------------------------------------------

resource "azurerm_storage_blob" "cats" {
  count = length(var.cat_names)

  name                   = "cats/${var.cat_names[count.index]}.json"
  storage_account_name   = azurerm_storage_account.pet_registry.name
  storage_container_name = azurerm_storage_container.pets.name
  type                   = "Block"
  source_content = jsonencode({
    name  = var.cat_names[count.index]
    type  = "Cat"
    index = count.index
  })

  lifecycle {
    precondition {
      condition     = length(var.cat_names[count.index]) >= 3
      error_message = "Cat names must be at least 3 characters long."
    }
  }
}

resource "azurerm_storage_blob" "dogs" {
  for_each = var.dogs_info

  name                   = "dogs/${each.key}.txt"
  storage_account_name   = azurerm_storage_account.pet_registry.name
  storage_container_name = azurerm_storage_container.pets.name
  type                   = "Block"
  source_content         = each.value

  depends_on = [azurerm_storage_blob.cats]

  lifecycle {
    postcondition {
      condition     = endswith(self.name, "${each.key}.txt")
      error_message = "The blob name should end with the dog's name."
    }
  }
}

# ---------------------------------------------------------------------------
# Rendered reports uploaded as blobs (templatefile + directives)
# ---------------------------------------------------------------------------

resource "azurerm_storage_blob" "cats_report" {
  name                   = "cats.txt"
  storage_account_name   = azurerm_storage_account.pet_registry.name
  storage_container_name = azurerm_storage_container.reports.name
  type                   = "Block"

  source_content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = [for c in azurerm_storage_blob.cats : { id = trimsuffix(basename(c.name), ".json"), length = length(trimsuffix(basename(c.name), ".json")) }]
    timestamp = timestamp()
    type      = "Cat"
    separator = var.separator
  })
}

resource "azurerm_storage_blob" "dogs_report" {
  name                   = "dogs.txt"
  storage_account_name   = azurerm_storage_account.pet_registry.name
  storage_container_name = azurerm_storage_container.reports.name
  type                   = "Block"

  source_content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = [for d in azurerm_storage_blob.dogs : { id = trimsuffix(basename(d.name), ".txt"), length = length(trimsuffix(basename(d.name), ".txt")) }]
    timestamp = timestamp()
    type      = "Dog"
    separator = var.separator
  })
}

# ---------------------------------------------------------------------------
# Archive built with a dynamic source block and uploaded to storage
# ---------------------------------------------------------------------------

data "archive_file" "pet_registry" {
  type        = "zip"
  output_path = "${path.module}/pet_registry.zip"

  dynamic "source" {
    for_each = [azurerm_storage_blob.cats_report, azurerm_storage_blob.dogs_report]
    content {
      content  = source.value.source_content
      filename = basename(source.value.name)
    }
  }
}

resource "azurerm_storage_blob" "pet_registry_zip" {
  name                   = "pet_registry.zip"
  storage_account_name   = azurerm_storage_account.pet_registry.name
  storage_container_name = azurerm_storage_container.reports.name
  type                   = "Block"
  source                 = data.archive_file.pet_registry.output_path
  content_md5            = data.archive_file.pet_registry.output_md5
}

# ---------------------------------------------------------------------------
# Sensitive foster parent data stored as a blob
# ---------------------------------------------------------------------------

resource "azurerm_storage_blob" "foster_parents" {
  name                   = "fosters.json"
  storage_account_name   = azurerm_storage_account.pet_registry.name
  storage_container_name = azurerm_storage_container.pets.name
  type                   = "Block"
  source_content         = jsonencode(var.foster_parents)
}

resource "local_file" "fosters" {
  content = templatefile("${path.module}/templates/foster_parents_report.tpl", {
    fosters = var.foster_parents
  })
  filename = "${path.module}/foster_parents_report.txt"
}
