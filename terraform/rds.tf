resource "random_password" "password" {
  length  = 16
  special = true
}

resource "aws_db_subnet_group" "default" {
  name       = "rds_subnet_group"
  subnet_ids = var.subnets

  tags = {
    Name  = "RDS subnet group"
    group = "terraform_proxy_rds"
  }
}

resource "aws_db_instance" "database_main" {
  identifier              = "my-database"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mariadb"
  engine_version          = "10.3.13"
  instance_class          = "db.t2.micro"
  username                = "admin"
  password                = random_password.password.result
  parameter_group_name    = "default.mariadb10.3"
  skip_final_snapshot     = true
  publicly_accessible     = false
  storage_encrypted       = true
  multi_az                = false
  backup_retention_period = 7
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name

  tags = {
    Name  = "my-database-main"
    group = "terraform_proxy_rds"
  }
}

resource "aws_db_instance" "database_replica" {
  identifier              = "my-database-replica"
  instance_class          = "db.t2.micro"
  copy_tags_to_snapshot   = true
  publicly_accessible     = false
  skip_final_snapshot     = true
  storage_encrypted       = true
  backup_retention_period = 1
  replicate_source_db     = aws_db_instance.database_main.identifier

  tags = {
    Name  = "my-database-replica"
    group = "terraform_proxy_rds"
  }
}
