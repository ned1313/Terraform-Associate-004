variable "name_prefix" {
  description = "Prefix for the resources name"
  type        = string
  default     = "taco-wagon"
}

variable "project_id" {
  description = "The GCP project ID to deploy resources into"
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources into"
  type        = string
  default     = "us-central1"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}
