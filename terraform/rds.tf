resource "random_password" "password" {
  length  = 16
  special = true
}

resource "aws_db_instance" "default" {
  identifier             = "my-database"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mariadb"
  engine_version         = "10.3.13"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = random_password.password.result
  parameter_group_name   = "default.mariadb10.3"
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted      = false
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}