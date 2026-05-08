provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = local.common_labels
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------

data "google_project" "current" {}

data "google_client_config" "current" {}

# ---------------------------------------------------------------------------
# Local values (including a ternary expression)
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.environment}-pet-registry"

  common_labels = {
    environment = var.environment
    managed_by  = "terraform"
    cost_center = var.environment == "prod" ? "1000" : "2000"
  }

  # Dynamic block source: firewall allow rules.
  firewall_rules = {
    http = {
      priority = 1000
      port     = "80"
    }
    https = {
      priority = 1010
      port     = "443"
    }
  }
}

# ---------------------------------------------------------------------------
# Random suffix (bucket names must be globally unique)
# ---------------------------------------------------------------------------

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# ---------------------------------------------------------------------------
# Networking: VPC + subnet + firewall with dynamic allow block
# ---------------------------------------------------------------------------

resource "google_compute_network" "main" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "${local.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id
}

resource "google_compute_firewall" "pets" {
  name        = "${local.name_prefix}-fw"
  network     = google_compute_network.main.id
  description = "Firewall rules for the pet registry example"
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = ["0.0.0.0/0"]

  dynamic "allow" {
    for_each = local.firewall_rules
    content {
      protocol = "tcp"
      ports    = [allow.value.port]
    }
  }
}

# ---------------------------------------------------------------------------
# Storage: GCS bucket that holds the registry entries and reports
# ---------------------------------------------------------------------------

resource "google_storage_bucket" "pet_registry" {
  name                        = "${local.name_prefix}-${random_string.suffix.result}"
  location                    = var.region
  storage_class               = "STANDARD"
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

# ---------------------------------------------------------------------------
# "Compute-like" registry entries: objects for cats (count) and dogs (for_each)
# ---------------------------------------------------------------------------

resource "google_storage_bucket_object" "cats" {
  count = length(var.cat_names)

  name   = "cats/${var.cat_names[count.index]}.json"
  bucket = google_storage_bucket.pet_registry.name
  content = jsonencode({
    name  = var.cat_names[count.index]
    type  = "Cat"
    index = count.index
  })
  content_type = "application/json"

  lifecycle {
    precondition {
      condition     = length(var.cat_names[count.index]) >= 3
      error_message = "Cat names must be at least 3 characters long."
    }
  }
}

resource "google_storage_bucket_object" "dogs" {
  for_each = var.dogs_info

  name         = "dogs/${each.key}.txt"
  bucket       = google_storage_bucket.pet_registry.name
  content      = each.value
  content_type = "text/plain"

  depends_on = [google_storage_bucket_object.cats]

  lifecycle {
    postcondition {
      condition     = endswith(self.name, "${each.key}.txt")
      error_message = "The object name should end with the dog's name."
    }
  }
}

# ---------------------------------------------------------------------------
# Rendered reports uploaded as objects (templatefile + directives)
# ---------------------------------------------------------------------------

resource "google_storage_bucket_object" "cats_report" {
  name   = "reports/cats.txt"
  bucket = google_storage_bucket.pet_registry.name

  content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = [for c in google_storage_bucket_object.cats : { id = trimsuffix(basename(c.name), ".json"), length = length(trimsuffix(basename(c.name), ".json")) }]
    timestamp = timestamp()
    type      = "Cat"
    separator = var.separator
  })
  content_type = "text/plain"
}

resource "google_storage_bucket_object" "dogs_report" {
  name   = "reports/dogs.txt"
  bucket = google_storage_bucket.pet_registry.name

  content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = [for d in google_storage_bucket_object.dogs : { id = trimsuffix(basename(d.name), ".txt"), length = length(trimsuffix(basename(d.name), ".txt")) }]
    timestamp = timestamp()
    type      = "Dog"
    separator = var.separator
  })
  content_type = "text/plain"
}

# ---------------------------------------------------------------------------
# Archive built with a dynamic source block and uploaded to the bucket
# ---------------------------------------------------------------------------

data "archive_file" "pet_registry" {
  type        = "zip"
  output_path = "${path.module}/pet_registry.zip"

  dynamic "source" {
    for_each = [google_storage_bucket_object.cats_report, google_storage_bucket_object.dogs_report]
    content {
      content  = source.value.content
      filename = basename(source.value.name)
    }
  }
}

resource "google_storage_bucket_object" "pet_registry_zip" {
  name         = "archives/pet_registry.zip"
  bucket       = google_storage_bucket.pet_registry.name
  source       = data.archive_file.pet_registry.output_path
  content_type = "application/zip"
}

# ---------------------------------------------------------------------------
# Sensitive foster parent data stored as an object
# ---------------------------------------------------------------------------

resource "google_storage_bucket_object" "foster_parents" {
  name         = "fosters.json"
  bucket       = google_storage_bucket.pet_registry.name
  content      = jsonencode(var.foster_parents)
  content_type = "application/json"
}

resource "local_file" "fosters" {
  content = templatefile("${path.module}/templates/foster_parents_report.tpl", {
    fosters = var.foster_parents
  })
  filename = "${path.module}/foster_parents_report.txt"
}
