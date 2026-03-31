resource "random_pet" "pookie" {
  length = var.pet_length[0]
  prefix = data.local_file.prefix.content
}

resource "random_pet" "schmoops" {
  length = var.pet_length[1]

  depends_on = [ random_pet.pookie ]
}

resource "local_file" "pookie" {
  content = random_pet.pookie.id
  filename = "pookie.txt"
}

data "local_file" "prefix" {
    filename = var.prefix_file
}