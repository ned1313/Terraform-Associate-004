output "bucket_id" {
  description = "ID of the S3 bucket created."
  value       = aws_s3_bucket.main.id
}

output "object_key" {
  description = "Key of the S3 object created."
  value       = aws_s3_object.main.key
}
