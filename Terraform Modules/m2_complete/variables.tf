variable "pet_type" {
  type        = string
  description = "The type of pet to create."
  default     = "dog"
}

variable "quantity" {
  type        = number
  description = "The number of pets to create."
  default     = 3
}