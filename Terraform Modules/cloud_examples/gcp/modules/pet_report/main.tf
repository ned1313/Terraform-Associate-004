resource "google_storage_bucket_object" "markdown_report" {
  bucket       = var.bucket
  name         = "${var.key_prefix}/pet_report.md"
  content_type = "text/markdown"
  content = templatefile("${path.module}/report.md.tftpl", {
    pet_type = var.pet_type
    pets     = var.pets
  })
}

resource "google_storage_bucket_object" "json_report" {
  bucket       = var.bucket
  name         = "${var.key_prefix}/pet_report.json"
  content_type = "application/json"
  content = jsonencode({
    pet_type = var.pet_type
    pets     = var.pets
  })
}
