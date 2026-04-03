variable "pet_length" {
  description = "Length of pet name to generate."
  type = list(number)
}

variable "add_dogs_prefix" {
  description = "Add a prefix to dogs"
  type = bool
  default = false
}