output "pookie" {
  description = "Value of pookie random pet (string)"
  value = title(random_pet.pookie[0].id)
}