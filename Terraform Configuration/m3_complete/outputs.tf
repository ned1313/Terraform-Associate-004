output "cats" {
  description = "Value of cats random pet (string)"
  value = title(random_pet.cats.id)
}

output "dogs" {
  description = "Value of dogs random pet (string)"
  value = title(random_pet.dogs.id)
}