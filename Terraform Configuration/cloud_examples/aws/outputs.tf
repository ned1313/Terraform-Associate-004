output "region" {
  description = "AWS region the pet registry was deployed into."
  value       = data.aws_region.current.region
}

output "aws_account_id" {
  description = "AWS account ID used for the deployment."
  value       = data.aws_caller_identity.current.account_id
}

output "bucket_name" {
  description = "Name of the S3 bucket storing the pet registry reports."
  value       = aws_s3_bucket.pet_registry.bucket
}

output "cat_parameters" {
  description = "SSM parameter names created for the cats."
  value       = [for c in aws_ssm_parameter.cats : title(c.name)]
}

output "dog_parameters" {
  description = "SSM parameter names created for the dogs."
  value       = [for d in aws_ssm_parameter.dogs : title(d.name)]
}

output "foster_parents" {
  description = "List of foster parent names."
  value       = [for parent, pref in var.foster_parents : parent]
  sensitive   = true
}
