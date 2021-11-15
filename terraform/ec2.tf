resource "aws_instance" "webserver" {
  ami                    = var.ami
  instance_type          = "t3a.nano"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  subnet_id              = element(var.subnets, 1)
  key_name               = aws_key_pair.pem-key.id
  tags = {
    Name  = "webserver"
    group = "terraform_proxy_rds"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}

resource "aws_instance" "proxysql" {
  ami                    = var.ami
  instance_type          = "t3a.nano"
  vpc_security_group_ids = [aws_security_group.proxysql_sg.id]
  subnet_id              = element(var.subnets, 1)
  key_name               = aws_key_pair.pem-key.id
  tags = {
    Name  = "proxysql"
    group = "terraform_proxy_rds"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}
