# Convenience targets for standing up and tearing down the ProxySQL + RDS demo.
#
# AWS credentials come from your environment — set AWS_PROFILE (and optionally
# AWS_REGION) before running the apply/configure/destroy targets, e.g.
#
#   AWS_PROFILE=my-profile make up
#
# The fmt/validate targets are read-only and need no AWS access.

TF_DIR      := terraform
ANSIBLE_DIR := ansible

.DEFAULT_GOAL := help

.PHONY: help fmt validate up configure down

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

fmt: ## Format the Terraform files
	terraform -chdir=$(TF_DIR) fmt -recursive

validate: ## Check formatting and validate the Terraform (no AWS access needed)
	terraform -chdir=$(TF_DIR) fmt -check -recursive
	terraform -chdir=$(TF_DIR) init -backend=false
	terraform -chdir=$(TF_DIR) validate

up: ## Create the infrastructure (terraform apply)
	terraform -chdir=$(TF_DIR) init
	terraform -chdir=$(TF_DIR) apply

configure: ## Configure RDS, the webserver and ProxySQL with Ansible
	cd $(ANSIBLE_DIR) && ansible-playbook rds.yml
	cd $(ANSIBLE_DIR) && ansible-playbook -i webserver_aws_ec2.yml webserver.yml
	cd $(ANSIBLE_DIR) && ansible-playbook -i proxysql_aws_ec2.yml proxysql.yml

down: ## Destroy the infrastructure (terraform destroy)
	terraform -chdir=$(TF_DIR) destroy
