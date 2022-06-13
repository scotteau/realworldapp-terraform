################################################################################
# Cloudfront CDN
################################################################################
resource "aws_cloudfront_distribution" "root_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_hosting_main.website_endpoint
    origin_id   = local.origin_id

    custom_header {
      name  = "Origin"
      value = "CloudFront"
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  aliases         = ["www.${var.domain_name}", var.domain_name]
  enabled         = true
  is_ipv6_enabled = true
  price_class     = var.price_class

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true

  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = var.global_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  logging_config {
    bucket = aws_s3_bucket.logs.bucket_domain_name
    prefix = "cloudfront/"
  }

  tags = local.default_tags

}

# bucket for logs
resource "aws_s3_bucket" "logs" {
  bucket = "logs.${var.domain_name}"
  tags   = local.default_tags
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.bucket
  acl    = "log-delivery-write"
}
