resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS Key for Zero-Trust S3 Bucket Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Zero-Trust-Storage"
  }
}

resource "aws_kms_alias" "s3_kms_key_alias" {
  name          = "alias/${var.environment}-s3-zero-trust-key"
  target_key_id = aws_kms_key.s3_kms_key.key_id
}