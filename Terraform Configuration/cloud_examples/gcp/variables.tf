variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "GCP region to deploy regional resources into."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment (dev or prod). Controls labeling and naming."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "subnet_cidr" {
  description = "CIDR block for the pet registry subnet."
  type        = string
  default     = "10.10.0.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "cat_names" {
  description = "List of cat names to register. Demonstrates count."
  type        = list(string)
}

variable "dogs_info" {
  description = "Map of dog names to breed descriptions. Demonstrates for_each."
  type        = map(string)
}

variable "separator" {
  description = "Separator used between columns in the pet report."
  type        = string
  default     = " | "

  validation {
    condition     = contains([" | ", " - ", " : ", " + "], var.separator)
    error_message = "Separator must be one of ' | ', ' - ', ' : ', or ' + '."
  }
}

variable "foster_parents" {
  description = "Map of foster parent names to their preferred pet type."
  type        = map(string)
  sensitive   = true
}
