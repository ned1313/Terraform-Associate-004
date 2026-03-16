variable "string_length" {
  description = "Length of random string. Defaults to 16."
  type        = number
  default     = 16
}

variable "file_name" {
  description = "Name of file to write to. No default."
  type        = string
}