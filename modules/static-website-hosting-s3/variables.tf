# global
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

# module
variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
}

variable "hosting_index_document" {
  description = "The name of the index document"
  type        = string
  default = "index.html"
}

variable "hosting_error_document" {
  description = "The name of the error document"
  type        = string
  default = "404.html"
}

