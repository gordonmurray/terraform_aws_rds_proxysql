terraform {

  required_version = ">= 1.5, < 2.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "3.43.0"

    }
  }

}

# Configure the AWS Provider
provider "aws" {
  region                  = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"

  default_tags {
    tags = {
      Project = "terraform_aws_rds_proxysql"
    }
  }
}
