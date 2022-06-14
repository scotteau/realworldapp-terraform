
variable "your_cidr" {
  description = "Your CIDR block for initial db seeding access"
  type        = list(string)
}

variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
}

variable "global_certificate_arn" {
  description = "certificate arn"
  type        = string
}