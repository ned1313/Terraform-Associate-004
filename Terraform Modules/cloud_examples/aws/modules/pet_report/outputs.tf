output "markdown_object_key" {
  description = "S3 key of the Markdown pet report."
  value       = aws_s3_object.markdown_report.key
}

output "json_object_key" {
  description = "S3 key of the JSON pet report."
  value       = aws_s3_object.json_report.key
}
