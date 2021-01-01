resource "aws_secretsmanager_secret" "rds_secret" {
  name                    = "rds"
  description             = "RDS details"
  recovery_window_in_days = 14

  tags = {
    Name  = "rds_admin"
    group = "terraform_proxy_rds"
  }
}

# Store the RDS details in Secrets Manager in json format
resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode(
    {
      "host"         = aws_db_instance.database_main.address,
      "host_replica" = aws_db_instance.database_replica.address,
      "username"     = "admin",
      "password"     = random_password.password.result
    }
  )
}
