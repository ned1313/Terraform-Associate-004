variable "pet_length" {
  description = "Length of pet name to generate."
  type = list(number)
}

variable "add_schmoops_prefix" {
  description = "Add a prefix to schmoops"
  type = bool
  default = false
}