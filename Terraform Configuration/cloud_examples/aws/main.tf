provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

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

  ingress_rules = {
    http  = { port = 80, cidr = "0.0.0.0/0" }
    https = { port = 443, cidr = "0.0.0.0/0" }
  }
}

# ---------------------------------------------------------------------------
# Networking: VPC + security group with a dynamic ingress block
# ---------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_security_group" "pets" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for the pet registry example"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = "Allow ${upper(ingress.key)} traffic"
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------
# Storage: S3 bucket that holds the generated reports
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "pet_registry" {
  bucket_prefix = "${local.name_prefix}-"
  force_destroy = true
}

# ---------------------------------------------------------------------------
# "Compute-like" registry: SSM parameters (Standard tier is free)
# ---------------------------------------------------------------------------

resource "aws_ssm_parameter" "cats" {
  count = length(var.cat_names)

  name = "/${local.name_prefix}/cats/${var.cat_names[count.index]}"
  type = "String"
  value = jsonencode({
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

resource "aws_ssm_parameter" "dogs" {
  for_each = var.dogs_info

  name  = "/${local.name_prefix}/dogs/${each.key}"
  type  = "String"
  value = each.value

  depends_on = [aws_ssm_parameter.cats]

  lifecycle {
    postcondition {
      condition     = endswith(self.arn, each.key)
      error_message = "The SSM parameter ARN should end with the dog's name."
    }
  }
}

# ---------------------------------------------------------------------------
# Rendered reports uploaded as S3 objects (templatefile + directives)
# ---------------------------------------------------------------------------

resource "aws_s3_object" "cats_report" {
  bucket = aws_s3_bucket.pet_registry.id
  key    = "reports/cats.txt"

  content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = [for c in aws_ssm_parameter.cats : { id = basename(c.name), length = length(basename(c.name)) }]
    timestamp = timestamp()
    type      = "Cat"
    separator = var.separator
  })
}

resource "aws_s3_object" "dogs_report" {
  bucket = aws_s3_bucket.pet_registry.id
  key    = "reports/dogs.txt"

  content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = [for d in aws_ssm_parameter.dogs : { id = basename(d.name), length = length(basename(d.name)) }]
    timestamp = timestamp()
    type      = "Dog"
    separator = var.separator
  })
}

# ---------------------------------------------------------------------------
# Archive built with a dynamic source block and uploaded to S3
# ---------------------------------------------------------------------------

data "archive_file" "pet_registry" {
  type        = "zip"
  output_path = "${path.module}/pet_registry.zip"

  dynamic "source" {
    for_each = [aws_s3_object.cats_report, aws_s3_object.dogs_report]
    content {
      content  = source.value.content
      filename = basename(source.value.key)
    }
  }
}

resource "aws_s3_object" "pet_registry_zip" {
  bucket      = aws_s3_bucket.pet_registry.id
  key         = "archives/pet_registry.zip"
  source      = data.archive_file.pet_registry.output_path
  source_hash = data.archive_file.pet_registry.output_base64sha256
}

# ---------------------------------------------------------------------------
# Sensitive foster parent data stored in a SecureString SSM parameter
# ---------------------------------------------------------------------------

resource "aws_ssm_parameter" "foster_parents" {
  name        = "/${local.name_prefix}/fosters"
  description = "Sensitive list of foster parents and their preferences."
  type        = "SecureString"
  value       = jsonencode(var.foster_parents)
}

resource "local_file" "fosters" {
  content = templatefile("${path.module}/templates/foster_parents_report.tpl", {
    fosters = var.foster_parents
  })
  filename = "${path.module}/foster_parents_report.txt"
}
