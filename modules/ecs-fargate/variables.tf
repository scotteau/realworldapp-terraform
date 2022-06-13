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

variable "db_url" {
  description = "Database url"
  type = string
}

variable "target_group_arn" {
  description = "the arn for the load-balancing group"
  type = string
}

variable "subnets_ids" {
  description = "A list of the subnets' IDs"
  type = list(string)
}

variable "security_groups" {
  description = "A list of the IDs for security groups"
  type = list(string)
}

variable "ecr_repository_url" {
  description = "The repository url of preferred docker image within ECR"
  type        = string
}

variable "family" {
  description = "An unique name for the task definition"
  type = string
}


variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "cpu_architecture" {
  type = string
}

variable "operating_system_family" {
  type = string
}

variable "storage_size" {
  description = "The storage size"
  type = number
}

variable "container_definition" {
  description = "The container definition"
}

variable "desired_count" {
  description = "The desired count of containers"
  type = number
}

variable "container_name" {
  description = "The container name"
  type = string
}

variable "container_port" {
  description = "The listened port on the container"
  type = string

}


variable "vpc_id" {
  description = "The Id for the vpc"
  type = string

}

variable "ecs_ingress_ports" {
  description = "Ports opened for ECS"
  type        = list(number)
}

variable "ingress_security_groups" {
  description = "A list of IDs for the allowed security groups"
  type = list(string)
}

variable "enabled_auto_scaling" {
  description = "Enabled auto-scaling group for ecs"
  type = bool
}


variable "autoscaling_capacity" {
  description = "The max and min capacity for ecs autoscaling"
  type = {
    max = number,
    min = number
  }
}

variable "autoscaling_based_on_ram_target_value" {
  description = "The target value for autoscaling policy based on ram"
  type = number
}

variable "autoscaling_based_on_cpu_target_value" {
  description = "The target value for autoscaling policy based on cpu"
  type = number
}

variable "your_cidr" {
  description = "Your CIDR block for initial db seeding access"
  type        = list(string)
}

variable "enabled_direct_access" {
  description = "Grant access to local machine within ecs security group"
  type = bool
}

variable "database_security_group_id" {
  description = "The ID of database's security group"
  type = string
}
