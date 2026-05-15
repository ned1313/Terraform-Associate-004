variable "pet_type" {
  type        = string
  description = "The type of pet included in the report."

  validation {
    condition = length(var.pet_type) > 2
    error_message = "Pet Type must have a value greater than 2"
  }
}

variable "pets" {
  description = "The pets to include in the report."

  type = list(object({
    name            = string
    type            = string
    id              = string
    age             = number
    adoption_status = string
  }))
}