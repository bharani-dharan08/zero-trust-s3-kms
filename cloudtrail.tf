data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "audit_logs" {
  bucket        = "${var.bucket_name}-audit-logs"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "Security-Audit-Logs"
  }
}

resource "aws_s3_bucket_public_access_block" "audit_logs_pab" {
  bucket                  = aws_s3_bucket.audit_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "audit_logs_policy" {
  bucket     = aws_s3_bucket.audit_logs.id
  depends_on = [aws_s3_bucket_public_access_block.audit_logs_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.audit_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${var.environment}-s3-security-audit-trail"
          }
        }
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.audit_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control",
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${var.environment}-s3-security-audit-trail"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "security_audit_trail" {
  name                          = "${var.environment}-s3-security-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.secure_storage.arn}/"]
    }
  }

  depends_on = [
    aws_s3_bucket_policy.audit_logs_policy
  ]
}