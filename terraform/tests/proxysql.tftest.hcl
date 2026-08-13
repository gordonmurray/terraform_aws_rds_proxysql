# Plan-level tests. The AWS provider is mocked, so this runs a real plan without
# AWS credentials. The point is to catch a provider upgrade that changes a
# default or drops an argument before it reaches a real apply, and to keep the
# choices below from being undone by accident.
#
# `terraform test` evaluates file(), which `terraform validate` does not, so
# ssh_public_key_path points at a throwaway key. `make test` generates it.

mock_provider "aws" {}

variables {
  vpc                 = "vpc-0123456789abcdef0"
  subnets             = ["subnet-0123456789abcdef0", "subnet-0abcdef01234567890"]
  my_ip_address       = "203.0.113.10"
  ssh_public_key_path = "tests/fixtures/id_rsa.pub"
}

run "instances_are_hardened" {
  command = plan

  assert {
    condition = alltrue([
      for i in [aws_instance.webserver, aws_instance.proxysql] :
      i.metadata_options[0].http_tokens == "required"
    ])
    error_message = "Both instances must require IMDSv2"
  }

  assert {
    condition = alltrue([
      for i in [aws_instance.webserver, aws_instance.proxysql] :
      i.root_block_device[0].encrypted
    ])
    error_message = "Both root volumes must be encrypted"
  }
}

run "the_databases_are_private_and_encrypted" {
  command = plan

  assert {
    condition = alltrue([
      for db in [aws_db_instance.database_main, aws_db_instance.database_replica] :
      db.storage_encrypted && db.publicly_accessible == false
    ])
    error_message = "Both databases must be encrypted and unreachable from the internet"
  }

  # The replica attaches by identifier. A rename that misses one end leaves a
  # standalone second database rather than a replica.
  assert {
    condition     = aws_db_instance.database_replica.replicate_source_db == aws_db_instance.database_main.identifier
    error_message = "The replica must follow the primary"
  }

  # manage_master_user_password is incompatible with a MariaDB read replica, so
  # the password stays generated here and kept in Secrets Manager instead.
  assert {
    condition     = aws_db_instance.database_main.manage_master_user_password != true
    error_message = "RDS-managed master passwords break the read replica"
  }
}

run "nothing_is_reachable_from_the_internet" {
  command = plan

  # SSH and HTTP come from one address only.
  assert {
    condition = alltrue([
      for r in [
        aws_security_group_rule.webserver_ingress_1,
        aws_security_group_rule.webserver_ingress_2,
        aws_security_group_rule.proxysql_ingress_1,
      ] : length(r.cidr_blocks) == 1 && contains(r.cidr_blocks, "${var.my_ip_address}/32")
    ])
    error_message = "SSH and HTTP must stay scoped to my_ip_address"
  }

  # The database path is security-group to security-group, never a CIDR, so
  # 3306 is not addressable even from inside the VPC. The paired group id is
  # only known after apply, so what is checked here is that no CIDR appears.
  assert {
    condition = alltrue([
      for r in [
        aws_security_group_rule.proxysql_ingress_2,
        aws_security_group_rule.rds_ingress_1,
      ] : r.cidr_blocks == null
    ])
    error_message = "Port 3306 must not be opened to a CIDR range"
  }
}

run "the_secret_suits_a_disposable_environment" {
  command = plan

  # A recovery window leaves the secret "scheduled for deletion" for days after
  # a teardown, which blocks the next apply from reusing the name.
  assert {
    condition     = aws_secretsmanager_secret.rds_secret.recovery_window_in_days == 0
    error_message = "The secret must be deleted immediately so the demo can be re-applied"
  }
}
