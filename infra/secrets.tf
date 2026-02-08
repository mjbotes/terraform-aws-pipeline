resource "aws_secretsmanager_secret" "db_password" {
  name                    = "rds-db-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
  })
}
