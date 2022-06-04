variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
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
  prefix = "${var.project_name}-${var.environment}"
}