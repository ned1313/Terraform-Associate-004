variable "pet_type" {
  description = "Type of pet being reported on (used as the report header)."
  type        = string
}

variable "pets" {
  description = "List of pets to include in the report."
  type = list(object({
    name            = string
    type            = string
    id              = number
    age             = number
    adoption_status = string
  }))
}

variable "bucket" {
  description = "Name of the GCS bucket where the report objects will be written."
  type        = string
}

variable "key_prefix" {
  description = "Prefix (folder) inside the bucket for the report objects."
  type        = string
  default     = "reports"
}
