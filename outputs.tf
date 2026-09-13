output "secure_bucket_name" {
  value       = aws_s3_bucket.secure_storage.id
  description = "Provisioned zero-trust S3 bucket name"
}

output "kms_key_arn" {
  value       = aws_kms_key.s3_kms_key.arn
  description = "Customer Managed Key ARN used for envelope encryption"
}

output "cloudtrail_arn" {
  value       = aws_cloudtrail.security_audit_trail.arn
  description = "CloudTrail audit pipeline ARN"
}