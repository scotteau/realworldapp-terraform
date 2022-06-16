variable "region" {
  description = "The name of the AWS region"
  type = string
}

variable "project_name" {
  description = "The project name, it's used for tags"
  type = string
}

variable "environment" {
  description = "The environment name, it's used for tags"
  type = string
}

variable "main_vpc_cidr" {
  description = "The CIDR block for the vpc"
  type = string
}

variable "public_cidr_blocks" {
  description = "A list of CIDR blocks for public subnets"
  type = list(string)
}

variable "private_cidr_blocks" {
  description = "A list of CIDR blocks for private subnets"
  type = list(string)
}



