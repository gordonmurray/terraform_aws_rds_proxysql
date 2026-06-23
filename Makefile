# Convenience targets for standing up and tearing down the ProxySQL + RDS demo.
#
# AWS credentials come from your environment — set AWS_PROFILE (and optionally
# AWS_REGION) before running the apply/configure/destroy targets, e.g.
#
#   AWS_PROFILE=my-profile make up
#
# The fmt/validate targets are read-only and need no AWS access.
#
# Don't want to install the tools? `make tools-build` builds a pinned
# toolchain image (see Dockerfile); `make lint` and `make shell` run through it.

TF_DIR      := terraform
ANSIBLE_DIR := ansible

# Pinned toolchain image (see Dockerfile), built by `make tools-build`.
TOOLS_IMAGE ?= terraform-aws-rds-proxysql-tools

# Run a read-only tool in the container with just the repo mounted.
DOCKER_RUN = docker run --rm -v $(CURDIR):/work -w /work $(TOOLS_IMAGE)

.DEFAULT_GOAL := help

.PHONY: help fmt validate up configure down tools-build shell lint

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

tools-build: ## Build the pinned toolchain image (see Dockerfile)
	docker build -t $(TOOLS_IMAGE) .

shell: ## Shell into the toolchain container with AWS creds + SSH key mounted
	docker run --rm -it \
		-v $(CURDIR):/work -w /work \
		-v $$HOME/.aws:/root/.aws:ro \
		-v $$HOME/.ssh:/root/.ssh:ro \
		-e AWS_PROFILE -e AWS_REGION \
		$(TOOLS_IMAGE) bash

lint: ## Run tflint and ansible-lint via the toolchain image
	$(DOCKER_RUN) sh -c "cd $(TF_DIR) && tflint --init && tflint"
	$(DOCKER_RUN) ansible-lint
