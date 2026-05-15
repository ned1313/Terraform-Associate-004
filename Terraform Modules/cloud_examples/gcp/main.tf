###############################################################################
# Networking — public registry module
#
# Demonstrates calling a public registry module. The version is pinned to a
# major release so that future-compatible patches are picked up automatically
# while shielding the configuration from breaking major-version changes.
###############################################################################

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.0"

  project_id   = var.project
  network_name = "${var.name_prefix}-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${var.name_prefix}-subnet"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      description           = "Primary subnet for the pet registry example."
    }
  ]
}

###############################################################################
# Pet generation
###############################################################################

resource "random_pet" "pets" {
  count  = var.quantity
  prefix = var.pet_type
  length = 2
}

###############################################################################
# Storage — single bucket holding both pet records and reports
###############################################################################

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "registry" {
  name                        = "${var.name_prefix}-${random_id.bucket_suffix.hex}"
  project                     = var.project
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
}

###############################################################################
# Pet records — one GCS object per pet (cheapest registry store)
###############################################################################

resource "google_storage_bucket_object" "pets" {
  count = var.quantity

  bucket = google_storage_bucket.registry.name
  name   = "pets/${random_pet.pets[count.index].id}.json"

  content_type = "application/json"
  content = jsonencode({
    name            = random_pet.pets[count.index].id
    type            = var.pet_type
    id              = count.index + 1
    age             = (count.index + 1) * 2
    adoption_status = "available"
  })
}

###############################################################################
# Pet report — local module
###############################################################################

module "pet_report" {
  source = "./modules/pet_report"

  pet_type = var.pet_type
  bucket   = google_storage_bucket.registry.name
  pets     = [for o in google_storage_bucket_object.pets : jsondecode(o.content)]
}
