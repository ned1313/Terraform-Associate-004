variable "region" {
  description = "AWS region to deploy the pet registry into."
  type        = string
  default     = "us-east-1"
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
