# Pinned toolchain for working on this repo — Terraform, Ansible and the
# lint/security/cost tools at fixed versions, so everyone (and CI) matches.
#
#   docker build -t terraform-aws-rds-proxysql-tools .
#   docker run --rm -it -v "$PWD":/work -w /work terraform-aws-rds-proxysql-tools bash
#
# Or via the Makefile: `make tools-build`, then `make lint` / `make shell`.
FROM python:3.12-slim-bookworm

# Tool versions — bump deliberately. The image pins the tools;
# .terraform.lock.hcl and ansible/requirements.yml pin the providers/collections.
ARG TERRAFORM_VERSION=1.10.5
ARG TFLINT_VERSION=0.63.1
ARG TRIVY_VERSION=0.71.2
ARG INFRACOST_VERSION=0.10.44
ARG ANSIBLE_CORE_VERSION=2.21.1
ARG ANSIBLE_LINT_VERSION=26.4.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl unzip git openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm /tmp/terraform.zip \
    && terraform version

# TFLint
RUN curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" -o /tmp/tflint.zip \
    && unzip /tmp/tflint.zip -d /usr/local/bin \
    && rm /tmp/tflint.zip \
    && tflint --version

# Trivy
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" -o /tmp/trivy.tar.gz \
    && tar -xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy \
    && rm /tmp/trivy.tar.gz \
    && trivy --version

# Infracost
RUN curl -fsSL "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-amd64.tar.gz" -o /tmp/infracost.tar.gz \
    && tar -xzf /tmp/infracost.tar.gz -C /tmp \
    && mv /tmp/infracost-linux-amd64 /usr/local/bin/infracost \
    && rm /tmp/infracost.tar.gz \
    && infracost --version

# Ansible, ansible-lint, and the Python deps the control node needs
# (boto3/botocore for amazon.aws, PyMySQL for the community.mysql modules)
RUN pip install --no-cache-dir \
        "ansible-core==${ANSIBLE_CORE_VERSION}" \
        "ansible-lint==${ANSIBLE_LINT_VERSION}" \
        boto3 botocore PyMySQL

# Bake the pinned Ansible collections into the image
COPY ansible/requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml && rm /tmp/requirements.yml

WORKDIR /work

CMD ["bash"]
