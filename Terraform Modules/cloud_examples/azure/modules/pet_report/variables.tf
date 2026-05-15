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

variable "storage_account_name" {
  description = "Name of the Azure Storage Account where the reports will be uploaded."
  type        = string
}

variable "container_name" {
  description = "Name of the blob container where the reports will be uploaded."
  type        = string
}

variable "key_prefix" {
  description = "Blob name prefix (folder) used for the generated report objects."
  type        = string
  default     = "reports"
}
