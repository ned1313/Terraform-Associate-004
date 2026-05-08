# ---------------------------------------------------------------------------
# Networking - public registry module (terraform-aws-modules/vpc/aws)
#
# This is the "module from the public registry" demonstration. The version
# constraint is intentionally relaxed (~> 6.0) so the module can be upgraded
# inside the major version. See the README for the m2 -> m3 upgrade story.
# ---------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs            = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    PetType = var.pet_type
  }
}

# ---------------------------------------------------------------------------
# "Compute" - one SSM parameter per pet. SSM Standard parameters are free and
# act as the lightweight registry entries the local module will report on.
# ---------------------------------------------------------------------------

resource "random_pet" "pets" {
  count  = var.quantity
  prefix = var.pet_type
  length = 2
}

resource "aws_ssm_parameter" "pets" {
  count = var.quantity

  name = "/${var.name_prefix}/${var.pet_type}/${random_pet.pets[count.index].id}"
  type = "String"

  value = jsonencode({
    name            = random_pet.pets[count.index].id
    type            = var.pet_type
    id              = format("%s-%03d", var.pet_type, count.index + 1)
    age             = (count.index + 1) * 2
    adoption_status = count.index % 2 == 0 ? "available" : "pending"
  })
}

# ---------------------------------------------------------------------------
# Storage - S3 bucket that holds the rendered reports
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "reports" {
  bucket_prefix = "${var.name_prefix}-reports-"
  force_destroy = true
}

# ---------------------------------------------------------------------------
# Local module - renders the Markdown + JSON pet reports and uploads them
# ---------------------------------------------------------------------------

module "pet_report" {
  source = "./modules/pet_report"

  pet_type   = var.pet_type
  bucket     = aws_s3_bucket.reports.id
  key_prefix = "reports"

  pets = [
    for p in aws_ssm_parameter.pets : jsondecode(p.value)
  ]
}
