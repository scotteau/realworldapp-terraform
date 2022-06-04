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

resource "aws_s3_bucket" "website_hosting_main" {
  bucket = var.domain_name
  tags   = local.default_tags
}

resource "aws_s3_bucket_acl" "website" {
  bucket = aws_s3_bucket.website_hosting_main.bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "public-access" {
  bucket = aws_s3_bucket.website_hosting_main.bucket
  policy = data.aws_iam_policy_document.website_policy.json
}

data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    resources = [
      "${aws_s3_bucket.website_hosting_main.arn}/*"
    ]
  }
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

resource "aws_s3_bucket" "website_hosting_www" {
  bucket = "www.${var.domain_name}"

  tags = local.default_tags
}


resource "aws_s3_bucket_website_configuration" "redirect" {
  bucket = aws_s3_bucket.website_hosting_www.bucket

  redirect_all_requests_to {
    host_name = var.domain_name
  }
}
