data "aws_route53_zone" "domain" {
  name = var.domain_name
}

resource "aws_route53_record" "root" {
  name    = var.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = var.distribution_domain_name
    zone_id                = var.distribution_hosted_zone_id
  }
}

resource "aws_route53_record" "www" {

  name    = "www.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = var.distribution_domain_name
    zone_id                = var.distribution_hosted_zone_id
  }
}


resource "aws_route53_record" "api" {
  name    = "${var.project_name}.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
  }
}





