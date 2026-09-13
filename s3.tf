resource "aws_s3_bucket" "secure_storage" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = {
    Environment = var.environment
    Compliance  = "PCI-DSS-GDPR-HIPAA"
    ManagedBy   = "Terraform"
  }
}

# 1. Enforce Strict Public Access Block
resource "aws_s3_bucket_public_access_block" "secure_storage_pab" {
  bucket                  = aws_s3_bucket.secure_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Server-Side KMS Encryption with S3 Bucket Key
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_storage_sse" {
  bucket = aws_s3_bucket.secure_storage.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# 3. Enable Versioning
resource "aws_s3_bucket_versioning" "secure_storage_versioning" {
  bucket = aws_s3_bucket.secure_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 4. Explicit Bucket Policy Denying Unencrypted HTTP Requests (TLS Enforcement)
resource "aws_s3_bucket_policy" "enforce_tls_policy" {
  bucket     = aws_s3_bucket.secure_storage.id
  depends_on = [aws_s3_bucket_public_access_block.secure_storage_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.secure_storage.arn,
          "${aws_s3_bucket.secure_storage.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}