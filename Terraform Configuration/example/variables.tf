variable "pet_length" {
  description = "Length of random pet"
  type = list(number)
}

variable "prefix_file" {
  description = "Filename for pet prefix"
  type = string
  default = "prefix.txt"

  validation {
    condition = endswith(var.prefix_file, ".txt")
    error_message = "Prefix file must end with .txt."
  }
}