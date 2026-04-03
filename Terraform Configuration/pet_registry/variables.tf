variable "cat_lengths" {
  description = "Length of pet name to generate."
  type        = list(number)
}

variable "dogs_info" {
  description = "Map of dog prefixes to lengths"
  type        = map(number)
}