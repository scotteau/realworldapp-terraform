variable "global_certificate_arn" {
  description = "certificate arn"
  type        = string
}

locals {
  origin_id = "S3-${var.domain_name}"
}

variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
}

variable "website_endpoint" {
  description = "The endpoint of website hosting s3 bucket"
  type = string
}

variable "price_class" {
  description = "The price_class for the distribution"
  type = string
}

locals {
  default_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
  }
  prefix = "${var.project_name}-${var.environment}"
}

variable "project_name" {
  description = "The name for the project"
  type        = string
}

variable "environment" {
  description = "Environment for the project"
  type        = string
}

