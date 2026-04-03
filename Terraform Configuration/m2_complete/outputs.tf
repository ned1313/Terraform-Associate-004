output "cats" {
  description = "Value of cats random pet (string)"
  value = random_pet.cats.id
}

output "dogs" {
  description = "Value of dogs random pet (string)"
  value = random_pet.dogs.id
}