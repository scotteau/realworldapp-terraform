output "ssl_certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.repo.repository_url
}