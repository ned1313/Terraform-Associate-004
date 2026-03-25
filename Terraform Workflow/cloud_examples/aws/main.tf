provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "main" {
  bucket_prefix = var.bucket_name_prefix
}

resource "aws_s3_object" "main" {
  bucket  = aws_s3_bucket.main.id
  key     = var.object_key
  content = var.object_content
}
