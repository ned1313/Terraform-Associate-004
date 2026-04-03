resource "random_pet" "pookie" {
  length = 2
  separator = " "
  prefix = data.local_file.prefix.content
}

resource "random_pet" "schmoops" {
  length = 3
  separator = " "

  depends_on = [ random_pet.pookie ]
}

resource "local_file" "pookie" {
  content  = random_pet.pookie.id
  filename = "pookie.txt"
}

data "local_file" "prefix" {
  filename = "prefix.txt"
}