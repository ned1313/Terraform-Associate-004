variable "name_prefix" {
  description = "Prefix for the resources name"
  type        = string
  default     = "taco-wagon"
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources into"
  type        = string
  default     = "eastus2"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
