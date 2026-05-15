resource "random_pet" "pets" {
  count = var.quantity

  prefix    = var.pet_type
  separator = "-"
  length    = 2
}

resource "random_id" "pets" {
  count = var.quantity

  byte_length = 4
}

resource "random_integer" "age" {
  count = var.quantity

  min = 1
  max = 15
}

resource "random_shuffle" "adoption_status" {
  count = var.quantity

  input        = ["available", "pending", "adopted"]
  result_count = 1
}

locals {
  pets = [
    for index in range(var.quantity) : {
      name            = random_pet.pets[index].id
      type            = var.pet_type
      id              = random_id.pets[index].hex
      age             = random_integer.age[index].result
      adoption_status = random_shuffle.adoption_status[index].result[0]
    }
  ]
}