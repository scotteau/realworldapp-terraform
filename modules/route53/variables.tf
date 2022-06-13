variable "project_name" {
  description = "The name for the project"
  type        = string
}

variable "environment" {
  description = "Environment for the project"
  type        = string
}

variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
}

variable "distribution_domain_name" {
  description = "The domain name for cdn distribution"
  type = string
}

variable "distribution_hosted_zone_id" {
  description = "The hosted zone id of cdn distribution"
  type = string

}

variable "alb_dns_name" {
  description = "The dns name for alb"
  type = string
}

variable "alb_zone_id" {
  description = "The zone id for alb"
  type = string
}

