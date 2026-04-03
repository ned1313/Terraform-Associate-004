locals {
  separator = " "
  pets = [random_pet.pookie, random_pet.schmoops]
}
resource "random_pet" "pookie" {
  length = var.pet_length[0]
  separator = local.separator
  prefix = trimspace(file("prefix.txt"))
}

resource "random_pet" "schmoops" {
  length = var.pet_length[1]
  separator = local.separator
  prefix = var.add_schmoops_prefix ? "king" : null

  depends_on = [ random_pet.pookie ]
}

resource "local_file" "pookie" {
  content  = templatefile("${path.module}/templates/pet_report.tpl", {
    pets = local.pets
    timestamp = timestamp()
  })
  filename = "pet_report.txt"
}