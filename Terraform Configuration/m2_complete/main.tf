locals {
  separator = " "
}

resource "random_pet" "cats" {
  length = var.pet_length[0]
  separator = local.separator
  prefix = data.local_file.prefix.content
}

resource "random_pet" "dogs" {
  length = var.pet_length[1]
  separator = local.separator

  depends_on = [ random_pet.cats ]
}

resource "local_file" "cats" {
  content  = random_pet.cats.id
  filename = "cats.txt"
}

resource "local_file" "dogs" {
  content  = random_pet.dogs.id
  filename = "dogs.txt"
}

data "local_file" "prefix" {
  filename = "prefix.txt"
}