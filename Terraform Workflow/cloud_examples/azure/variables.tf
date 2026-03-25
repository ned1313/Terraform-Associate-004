variable "location" {
  description = "Azure region for resources. Defaults to East US."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group. No default."
  type        = string
}

variable "subscription_id" {
  description = "Subscription to use for Azure"
  type        = string
}