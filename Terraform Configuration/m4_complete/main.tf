locals {
  separator = " "
}

resource "random_pet" "cats" {
  count     = length(var.cat_lengths)
  length    = var.cat_lengths[count.index]
  separator = local.separator
  prefix    = trimspace(file("prefix.txt"))
}

resource "random_pet" "dogs" {
  for_each  = var.dogs_info
  length    = each.value
  separator = local.separator
  prefix    = each.key

  depends_on = [random_pet.cats]
}

resource "local_file" "cats" {
  content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = random_pet.cats
    timestamp = timestamp()
    type      = "Cat"
  })
  filename = "cats.txt"
}

resource "local_file" "dogs" {
  content = templatefile("${path.module}/templates/pet_report.tpl", {
    pets      = random_pet.dogs
    timestamp = timestamp()
    type      = "Dog"
  })
  filename = "dogs.txt"
}

resource "archive_file" "pet_registry" {
  type        = "zip"
  output_path = "pet_registry.zip"

  dynamic "source" {
    for_each = [local_file.cats, local_file.dogs]
    content {
      content  = source.value.content
      filename = source.value.filename
    }
  }
}