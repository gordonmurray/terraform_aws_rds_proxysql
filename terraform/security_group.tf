resource "aws_security_group" "webserver_sg" {
  name        = "webserver"
  description = "webserver security group"
  vpc_id      = var.vpc
  tags = {
    Name  = "webserver_security_group"
    group = "terraform_proxy_rds"

  }
}

resource "aws_security_group" "proxysql_sg" {
  name        = "proxysql"
  description = "proxysql security group"
  vpc_id      = var.vpc
  tags = {
    Name  = "proxysql_security_group"
    group = "terraform_proxy_rds"

  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds"
  description = "rds instance security group"
  vpc_id      = var.vpc
  tags = {
    Name  = "rds_security_group"
    group = "terraform_proxy_rds"

  }
}