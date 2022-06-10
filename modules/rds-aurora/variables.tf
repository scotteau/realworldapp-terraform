# Global variables
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

# module specific variables
variable "cluster_name" {
  description = "The name for RDS aurora postgres cluster"
  type = string
}

variable "postgres_version" {
  description = "The Postgres engine version"
  type = string
}

variable "instance_class" {
  description = "The EC2 instance class"
  type = string
}

variable "vpc_id" {
  description = "The ID for the VPC"
  type = string
}

variable "database_ingress_ports" {
  description = "Ports opened for database"
  type        = list(number)
}

variable "database" {
  description = "A list of cidr blocks for private subnets hosting database"
  type        = list(string)
}

variable "enable_direct_access" {
  description = "Enable direct access to database subnet"
  type = bool
}

variable "your_cidr" {
  description = "Your CIDR block for initial db seeding access"
  type        = list(string)
}

variable "internet_gateway_id" {
  description = "The ID of the main vpc internet gateway"
  type = string
}

# db variables
variable "db_name" {
  type = string
}

variable "master_username" {
  type = string
}

locals {
  dir = "/${var.environment}/${var.project_name}/database"
}

locals {
  protocol = "postgresql"
  username = aws_ssm_parameter.master_username.value
  password = aws_ssm_parameter.master_password.value
  host     = module.rds_aurora.cluster_endpoint
  port     = module.rds_aurora.cluster_port
}

variable "cluster_instances" {
  description = "The configuration of db instances"
}


