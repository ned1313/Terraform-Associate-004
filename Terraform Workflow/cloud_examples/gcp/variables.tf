variable "project_name" {
  description = "Display name for the Google Cloud project. No default."
  type        = string
}

variable "billing_account" {
  description = "Billing account ID to associate with the project. No default."
  type        = string
}

variable "org_id" {
  description = "Organization ID for the project. No default."
  type        = string
}

variable "region" {
  description = "Google Cloud region for resources. Defaults to us-central1."
  type        = string
  default     = "us-central1"
}

variable "bucket_name_prefix" {
  description = "Prefix for the Cloud Storage bucket name. No default."
  type        = string
}
