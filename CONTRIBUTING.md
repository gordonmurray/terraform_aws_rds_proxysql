# Contributing

Thanks for taking a look. This repo stands up a small ProxySQL + RDS environment with
Terraform and Ansible — it's meant for testing and experimentation, so it's a friendly
place to try things out.

## Prerequisites

- Terraform >= 1.5 (OpenTofu works too)
- Ansible
- An AWS account and credentials with permission to create EC2, RDS and Secrets Manager resources
- Optional but recommended: [pre-commit](https://pre-commit.com), `make`, and `tflint`

## Getting set up

1. Fork and clone the repo.
2. Point Terraform at an SSH public key by setting `ssh_public_key_path` in a gitignored
   `terraform/terraform.tfvars`:

   ```
   ssh_public_key_path = "~/.ssh/id_rsa.pub"
   ```

3. AWS credentials come from your environment — set `AWS_PROFILE` (and optionally `AWS_REGION`)
   before running anything that touches AWS. Nothing is hardcoded.
4. Install the pre-commit hooks once:

   ```
   pre-commit install
   ```

## Running it locally

The `Makefile` wraps the whole flow:

```
make up          # terraform init + apply
make configure   # the Ansible playbooks (rds, webserver, proxysql), in order
make down        # terraform destroy
```

Run `make help` to see all targets.

## Running the checks

```
make validate    # terraform fmt -check, init and validate — no AWS access needed
```

`pre-commit` runs `terraform fmt`, `tflint`, `ansible-lint` and a few whitespace checks on every
commit. CI runs `terraform fmt` and `init` on every pull request and must pass before a PR merges;
`tflint` also runs in CI.

## Opening a pull request

- Branch off `main` (e.g. `fix/short-description`).
- Keep each PR focused on one change.
- Make sure `make validate` passes and the pre-commit hooks are clean.
- Open the PR against `main` and describe what changed and why. CI must be green to merge.
