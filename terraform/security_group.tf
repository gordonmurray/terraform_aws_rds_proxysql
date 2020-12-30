resource "aws_security_group" "webserver_sg" {
  name        = "webserver"
  description = "webserver security group"
  vpc_id      = var.vpc
  tags = {
    Name = "webserver_security_group"
  }
}

resource "aws_security_group" "proxysql_sg" {
  name        = "proxysql"
  description = "proxysql security group"
  vpc_id      = var.vpc
  tags = {
    Name = "proxysql_security_group"
  }
}