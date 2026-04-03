locals {
  separator = " "
}

resource "random_pet" "cats" {
  length = var.pet_length[0]
  separator = local.separator
  prefix = trimspace(file("prefix.txt"))
}

resource "random_pet" "dogs" {
  length = var.pet_length[1]
  separator = local.separator
  prefix = var.add_dogs_prefix ? "king" : null

  depends_on = [ random_pet.cats ]
}

resource "local_file" "cats" {
  content  = templatefile("${path.module}/templates/pet_report.tpl", {
    pets = [random_pet.cats ]
    timestamp = timestamp()
    type = "Cat"
  })
  filename = "cats.txt"
}

resource "local_file" "dogs" {
  content  = templatefile("${path.module}/templates/pet_report.tpl", {
    pets = [random_pet.dogs ]
    timestamp = timestamp()
    type = "Dog"
  })
  filename = "dogs.txt"
}