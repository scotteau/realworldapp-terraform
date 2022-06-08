output "ssl_certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.repo.repository_url
}

output "ssl_certificate_arn_Local" {
  value = aws_acm_certificate.cert_local.arn
}