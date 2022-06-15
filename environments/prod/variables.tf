locals {
  project_name = "realworldapp"
  environment  = "prod"
  region       = "ap-southeast-2"
  prefix       = "${local.project_name}-${local.environment}"
}

variable "your_cidr" {
  description = "Your CIDR block for initial db seeding access"
  type        = list(string)
}

variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
}

variable "global_certificate_arn" {
  description = "certificate arn for cloudfront distribution"
  type        = string
}

variable "certificate_arn" {
  description = "certificate arn for alb"
  type = string
}

variable "ecr_repository_url" {
  description = "The repository url of preferred docker image within ECR"
  type        = string
}