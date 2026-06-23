resource "aws_instance" "webserver" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t3a.nano"
  vpc_security_group_ids  = [aws_security_group.webserver_sg.id]
  subnet_id               = element(var.subnets, 1)
  key_name                = aws_key_pair.pem-key.id
  disable_api_termination = var.disable_api_termination

  tags = {
    Name  = "webserver"
    group = "terraform_proxy_rds"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }
}

resource "aws_instance" "proxysql" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t3a.nano"
  vpc_security_group_ids  = [aws_security_group.proxysql_sg.id]
  subnet_id               = element(var.subnets, 1)
  key_name                = aws_key_pair.pem-key.id
  disable_api_termination = var.disable_api_termination

  tags = {
    Name  = "proxysql"
    group = "terraform_proxy_rds"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }
}
