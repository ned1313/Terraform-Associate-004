variable "pet_type" {
  type        = string
  description = "The type of pet included in the report."
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