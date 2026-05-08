resource "azurerm_storage_blob" "markdown_report" {
  name                   = "${var.key_prefix}/${var.pet_type}.md"
  storage_account_name   = var.storage_account_name
  storage_container_name = var.container_name
  type                   = "Block"
  content_type           = "text/markdown"

  source_content = templatefile("${path.module}/report.md.tftpl", {
    pet_type = var.pet_type
    pets     = var.pets
  })
}

resource "azurerm_storage_blob" "json_report" {
  name                   = "${var.key_prefix}/${var.pet_type}.json"
  storage_account_name   = var.storage_account_name
  storage_container_name = var.container_name
  type                   = "Block"
  content_type           = "application/json"

  source_content = jsonencode({
    pet_type = var.pet_type
    pets     = var.pets
  })
}
