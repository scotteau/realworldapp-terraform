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

variable "vpc_id" {
  description = "The ID for the vpc"
  type = string
}

#variable "security_groups" {
#  description = "A list of security group IDs to assign to the LB"
#  type = list(string)
#}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB"
  type = list(string)
}

variable "alb_ingress_ports" {
  description = "A list of Port number for ingress rules of alb"
  type = list(number)
}

variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
}

variable "certificate_arn" {
  type = string
}
