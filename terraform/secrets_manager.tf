resource "aws_secretsmanager_secret" "rds_secret" {
  kms_key_id              = aws_kms_key.default.key_id
  name                    = "rds"
  description             = "RDS details"
  recovery_window_in_days = 14

  tags = {
    Name  = "rds_admin"
    group = "terraform_proxy_rds"
  }
}

# Store the RDS connection details in Secrets Manager in json format.
# The master password is NOT kept here — it lives in the RDS-managed secret;
# we only record a pointer to it (master_secret_arn) so Ansible can read it.
resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode(
    {
      "host"              = aws_db_instance.database_main.address,
      "host_replica"      = aws_db_instance.database_replica.address,
      "username"          = "admin",
      "master_secret_arn" = aws_db_instance.database_main.master_user_secret[0].secret_arn
    }
  )
}
