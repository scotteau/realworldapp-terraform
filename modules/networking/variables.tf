variable "region" {
  description = "The name of the AWS region"
  type = string
}

variable "project_name" {
  description = "The name for the project"
  type        = string
}

variable "environment" {
  description = "Environment for the project"
  type        = string
}

locals {
  default_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
  }
  prefix = "${var.project_name}-${var.environment}"
}

variable "cidr_block" {
  type = string
  description = "The CIDR block for your VPC"
}

variable "public" {
  description = "A list of cidr blocks for public subnets"
  type        = list(string)
}

variable "private" {
  description = "A list of cidr blocks for private subnets"
  type        = list(string)
}

variable "database" {
  description = "A list of cidr blocks for private subnets hosting database"
  type        = list(string)
}


