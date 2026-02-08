output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

output "web_url" {
  value = "http://${aws_lb.web.dns_name}"
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "rds_database" {
  value = aws_db_instance.default.db_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}
