variable "project_id" {
  description = "The GCP project ID to deploy resources into"
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources into"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone to deploy the instance into"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type for the compute instance"
  type        = string
  default     = "e2-micro"
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The self link of the subnet to deploy resources into"
  type        = string
}
