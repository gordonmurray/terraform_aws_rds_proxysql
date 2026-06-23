terraform {

  required_version = ">= 1.5, < 2.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

}

# Configure the AWS Provider. Credentials come from the standard chain
# (AWS_PROFILE / environment / shared config), not hardcoded here.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "terraform_aws_rds_proxysql"
    }
  }
}
