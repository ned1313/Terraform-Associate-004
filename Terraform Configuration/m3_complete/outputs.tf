output "pookie" {
  description = "Value of pookie random pet (string)"
  value = title(random_pet.pookie.id)
}

output "schmoops" {
  description = "Value of schmoops random pet (string)"
  value = title(random_pet.schmoops.id)
}