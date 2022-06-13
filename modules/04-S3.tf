

# bucket for logs
resource "aws_s3_bucket" "logs" {
  bucket = "logs.${var.domain_name}"
  tags   = local.default_tags
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.bucket
  acl    = "log-delivery-write"
}
