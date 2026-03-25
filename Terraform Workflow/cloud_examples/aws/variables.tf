variable "region" {
  description = "AWS region for resources. Defaults to us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  description = "Prefix for name of the S3 bucket. No default."
  type        = string
}

variable "object_key" {
  description = "Key for the S3 bucket object. No default."
  type        = string
}

variable "object_content" {
  description = "Content of the S3 bucket object. Defaults to 'Hello, Terraform!'"
  type        = string
  default     = "Hello, Terraform!"
}
