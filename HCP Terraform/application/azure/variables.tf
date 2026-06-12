variable "location" {
  description = "Azure region to deploy resources into"
  type        = string
  default     = "eastus2"
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the virtual machine"
  type        = string
  sensitive   = true

  default     = "CH@ngeMe123!ABC"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy resources into"
  type        = string
}
