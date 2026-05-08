output "vpc_id" {
  description = "ID of the VPC created by the public registry module."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets created by the public registry module."
  value       = module.vpc.public_subnets
}

output "bucket_name" {
  description = "Name of the S3 bucket holding the generated pet reports."
  value       = aws_s3_bucket.reports.bucket
}

output "pets" {
  description = "The registered pets."
  value       = [for p in aws_ssm_parameter.pets : jsondecode(nonsensitive(p.value))]
}

output "markdown_report_object" {
  description = "S3 key of the rendered Markdown report."
  value       = module.pet_report.markdown_object_key
}

output "json_report_object" {
  description = "S3 key of the rendered JSON report."
  value       = module.pet_report.json_object_key
}
