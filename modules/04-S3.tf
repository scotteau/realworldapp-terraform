################################################################################
# s3
################################################################################
variable "domain_name" {
  description = "The domain name of the hosted website"
  type        = string
}

variable "hosting_index_document" {
  description = "The name of the index document"
  type        = string
}

variable "hosting_error_document" {
  description = "The name of the error document"
  type        = string
}

# bucket for root domain hosting
resource "aws_s3_bucket" "website_hosting_main" {
  bucket = var.domain_name
  tags   = local.default_tags
}

resource "aws_s3_bucket_cors_configuration" "website_hosting_main" {
  bucket = aws_s3_bucket.website_hosting_main.bucket
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "website" {
  bucket = aws_s3_bucket.website_hosting_main.bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "public-access" {
  bucket = aws_s3_bucket.website_hosting_main.bucket
  policy = templatefile("${path.root}/templates/s3_policy.json", { bucket : var.domain_name })
}


resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_hosting_main.bucket

  index_document {
    suffix = var.hosting_index_document
  }

  error_document {
    key = var.hosting_error_document
  }
}

# bucket for www domain redirecting
resource "aws_s3_bucket" "website_hosting_www" {
  bucket = "www.${var.domain_name}"
  tags   = local.default_tags
}

resource "aws_s3_bucket_acl" "public_read" {
  bucket = aws_s3_bucket.website_hosting_www.bucket
  acl    = "public-read"
}


resource "aws_s3_bucket_website_configuration" "redirect" {
  bucket = aws_s3_bucket.website_hosting_www.bucket

  redirect_all_requests_to {
    host_name = var.domain_name
    protocol  = "http"
  }
}

resource "aws_s3_bucket_policy" "www_public-access" {
  bucket = aws_s3_bucket.website_hosting_www.bucket
  policy = templatefile("${path.root}/templates/s3_policy.json", { bucket : "www.${var.domain_name}" })
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
