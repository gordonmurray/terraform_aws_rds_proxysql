resource "aws_key_pair" "pem-key" {
  key_name   = "proxysql_pem"
  public_key = file("~/.ssh/id_rsa.pub")
}