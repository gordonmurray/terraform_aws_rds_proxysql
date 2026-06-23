resource "aws_key_pair" "pem-key" {
  key_name   = "proxysql_pem"
  public_key = file(var.ssh_public_key_path)

  tags = {
    group = "terraform_proxy_rds"
  }
}