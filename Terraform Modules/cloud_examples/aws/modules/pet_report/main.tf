resource "aws_s3_object" "markdown_report" {
  bucket       = var.bucket
  key          = "${var.key_prefix}/${var.pet_type}.md"
  content_type = "text/markdown"

  content = templatefile("${path.module}/report.md.tftpl", {
    pet_type = var.pet_type
    pets     = var.pets
  })
}

resource "aws_s3_object" "json_report" {
  bucket       = var.bucket
  key          = "${var.key_prefix}/${var.pet_type}.json"
  content_type = "application/json"

  content = jsonencode({
    pet_type = var.pet_type
    pets     = var.pets
  })
}
