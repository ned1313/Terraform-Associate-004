resource "local_file" "markdown_report" {
  filename = "${path.root}/reports/${var.pet_type}.md"

  content = templatefile("${path.module}/report.md.tftpl", {
    pet_type = var.pet_type
    pets     = var.pets
  })
}

resource "local_file" "json_report" {
  filename = "${path.root}/reports/${var.pet_type}.json"

  content = jsonencode({
    pet_type = var.pet_type
    pets     = var.pets
  })
}