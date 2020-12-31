
resource "aws_security_group_rule" "webserver_ingress_1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "webserver_egress_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "Allow all out"
}

resource "aws_security_group_rule" "proxysql_ingress_1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.proxysql_sg.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "proxysql_ingress_2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
  security_group_id        = aws_security_group.proxysql_sg.id
  description              = "ProxySQL access"
}

resource "aws_security_group_rule" "proxysql_egress_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.proxysql_sg.id
  description       = "Allow all out"
}

resource "aws_security_group_rule" "rds_ingress_1" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxysql_sg.id
  security_group_id        = aws_security_group.webserver_sg.id
  description              = "ProxySQL access"
}

resource "aws_security_group_rule" "rds_egress_1" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "Allow 3306 out"
}
