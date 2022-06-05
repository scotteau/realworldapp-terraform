################################################################################
# Certificate
################################################################################
provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "my-terraform-shared-state"
    key = "realworldapp/dev/ecr_and_cert/terraform.tfstate"
    region = "ap-southeast-2"

    dynamodb_table = "terraform-shared-state-locks"
    encrypt = true
  }
}

resource "aws_acm_certificate" "cert" {
  provider          = aws.us-east-1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = ["*.${var.domain_name}"]


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}


################################################################################
# Route53
################################################################################

resource "aws_route53_zone" "domain" {
  name = var.domain_name
}
