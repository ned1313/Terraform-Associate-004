output "cats" {
  description = "Value of cats random pet (tuple)"
  value       = [for cat in random_pet.cats : title(cat.id)]
}

output "dogs" {
  description = "Value of dogs random pet (string)"
  value       = [for dog in random_pet.dogs : title(dog.id)]
}

output "fosters" {
  description = "List of foster parents"
  value = [ for foster, pet in var.foster_parents : foster ]
  sensitive = true
}