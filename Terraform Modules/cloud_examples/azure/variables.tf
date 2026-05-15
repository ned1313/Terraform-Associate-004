variable "location" {
  description = "Azure region to deploy the pet registry into."
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Azure subscription ID. Leave empty to use the ARM_SUBSCRIPTION_ID environment variable or the active az CLI subscription."
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Prefix applied to created resource names."
  type        = string
  default     = "pet-registry"
}

variable "pet_type" {
  description = "The type of pet to register (e.g. dog, cat, hamster)."
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
