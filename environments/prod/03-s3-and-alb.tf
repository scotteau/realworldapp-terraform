module "static-site-hosting" {
  source = "../../modules/static-website-hosting-s3"

  project_name = local.project_name
  environment  = local.environment
  domain_name  = var.domain_name

  hosting_index_document = "index.html"
  hosting_error_document = "index.html"

  global_certificate_arn = var.global_certificate_arn
}

module "alb" {
  source = "../../modules/alb"

  project_name = local.project_name
  environment = local.environment
  domain_name = var.domain_name

  vpc_id = module.vpc.vpc_id
  alb_ingress_ports = [80, 443]
  certificate_arn = var.certificate_arn
  subnets = module.vpc.public_subnets[*].id
}
