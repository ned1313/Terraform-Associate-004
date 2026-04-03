resource "random_pet" "cats" {
  length = 2
  separator = " "
  prefix = data.local_file.prefix.content
}

resource "random_pet" "dogs" {
  length = 3
  separator = " "

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