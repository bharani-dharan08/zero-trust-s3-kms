variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS Region"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment environment designation"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique name for the target S3 bucket"
}