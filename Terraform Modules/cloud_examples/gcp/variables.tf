variable "project" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources (e.g. subnets, GCS bucket)."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for zonal resources."
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefix used for naming the resources created by this configuration."
  type        = string
  default     = "pet-registry"
}

variable "pet_type" {
  description = "Type of pet to register (used in random_pet prefix and report)."
  type        = string
  default     = "dog"
}

variable "quantity" {
  description = "Number of pets to register."
  type        = number
  default     = 3

  validation {
    condition     = var.quantity > 0 && var.quantity <= 20
    error_message = "Quantity must be between 1 and 20."
  }
}
