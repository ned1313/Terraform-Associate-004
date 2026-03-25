variable "location" {
  description = "Azure region for resources. Defaults to East US."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group. No default."
  type        = string
}
