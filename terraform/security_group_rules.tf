
resource "aws_security_group_rule" "webserver_ingress_1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "webserver_ingress_2" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "HTTP access (restricted to my_ip_address)"
}

resource "aws_security_group_rule" "webserver_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "HTTPS out (package mirrors, Adminer download)"
}

resource "aws_security_group_rule" "webserver_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "HTTP out (package mirrors)"
}

resource "aws_security_group_rule" "webserver_egress_dns_udp" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "DNS resolution"
}

resource "aws_security_group_rule" "webserver_egress_dns_tcp" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
  description       = "DNS resolution (TCP fallback)"
}

resource "aws_security_group_rule" "webserver_egress_proxysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxysql_sg.id
  security_group_id        = aws_security_group.webserver_sg.id
  description              = "MySQL to ProxySQL"
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
  description              = "Webserver proxysql access"
}

resource "aws_security_group_rule" "proxysql_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.proxysql_sg.id
  description       = "HTTPS out (package mirrors)"
}

resource "aws_security_group_rule" "proxysql_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.proxysql_sg.id
  description       = "HTTP out (package mirrors)"
}

resource "aws_security_group_rule" "proxysql_egress_dns_udp" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.proxysql_sg.id
  description       = "DNS resolution"
}

resource "aws_security_group_rule" "proxysql_egress_dns_tcp" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.proxysql_sg.id
  description       = "DNS resolution (TCP fallback)"
}

resource "aws_security_group_rule" "proxysql_egress_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sg.id
  security_group_id        = aws_security_group.proxysql_sg.id
  description              = "MySQL to RDS"
}

resource "aws_security_group_rule" "rds_ingress_1" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxysql_sg.id
  security_group_id        = aws_security_group.rds_sg.id
  description              = "ProxySQL access"
}

resource "aws_security_group_rule" "rds_egress_proxysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxysql_sg.id
  security_group_id        = aws_security_group.rds_sg.id
  description              = "MySQL to ProxySQL"
}
