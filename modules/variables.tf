#################################################################################
## global variable
#################################################################################
#variable "project_name" {
#  description = "The name for the project"
#  type        = string
#}
#
#variable "environment" {
#  description = "Environment for the project"
#  type        = string
#}
#
#variable "public" {
#  description = "A list of cidr blocks for public subnets"
#  type        = list(string)
#}
#
#variable "private" {
#  description = "A list of cidr blocks for private subnets"
#  type        = list(string)
#}
#
#variable "database" {
#  description = "A list of cidr blocks for private subnets hosting database"
#  type        = list(string)
#}
#
#locals {
#  default_tags = {
#    ManagedBy   = "Terraform"
#    Project     = var.project_name
#    Environment = var.environment
#  }
#  prefix = "${var.project_name}-${var.environment}"
#}
#
