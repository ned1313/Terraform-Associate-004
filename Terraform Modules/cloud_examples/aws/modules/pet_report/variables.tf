variable "pet_type" {
  description = "The type of pet included in the report."
  type        = string
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

variable "bucket" {
  description = "Name of the S3 bucket where the reports will be uploaded."
  type        = string
}

variable "key_prefix" {
  description = "Key prefix (folder) used for the generated report objects."
  type        = string
  default     = "reports"
}
