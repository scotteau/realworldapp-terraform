output "public_subnets_ids" {
  value = module.vpc.public_subnets[*].id
}

output "private_subnets_ids" {
  value = module.vpc.private_subnets[*].id
}