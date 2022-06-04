################################################################################
# Cloudfront CDN
################################################################################

locals {
  root_origin_id = aws_s3_bucket.website_hosting_main.bucket_regional_domain_name
  www_origin_id  = aws_s3_bucket.website_hosting_www.bucket_regional_domain_name
}

resource "aws_cloudfront_distribution" "root_s3_distribution" {

  origin {
    domain_name = aws_s3_bucket.website_hosting_main.website_endpoint
    origin_id   = local.root_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases             = [var.domain_name]
  price_class         = "PriceClass_200"
  default_root_object = var.hosting_index_document

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.root_origin_id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }



  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}


resource "aws_cloudfront_distribution" "www_s3_distribution" {
  origin {
    domain_name = "www.${var.domain_name}"
    origin_id   = local.www_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled = true
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.www_origin_id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class         = "PriceClass_200"
  default_root_object = var.hosting_index_document

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}


variable "certificate_arn" {
  description = "SSL certificate's arn"
  type = string
}
