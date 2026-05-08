variable "cat_lengths" {
  description = "Length of pet name to generate."
  type        = list(number)
}

variable "dogs_info" {
  description = "Map of dog prefixes to lengths"
  type        = map(number)
}

variable "separator" {
  description = "Separator for pet names"
  type = string
  default = " "

  validation {
    condition = contains([" ","-",":","+"], var.separator)
    error_message = "Separator must be one of the following: ' ', '-', ':', '+'"
  }
}