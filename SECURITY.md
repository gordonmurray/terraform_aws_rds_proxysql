# Security Policy

## Supported versions

This is a small example project for testing ProxySQL with RDS. There are no tagged releases —
the latest `main` is the only supported version, and fixes land there.

## Reporting a vulnerability

Please don't open a public issue for a security problem.

Use GitHub's private vulnerability reporting instead: go to the **Security** tab of this
repository and choose **Report a vulnerability**. That opens a private advisory visible only
to the maintainer.

This is a personal open-source project maintained in spare time, so please allow a little time
for a response — you'll get an acknowledgement once it's been seen.

## Scope

This project provisions real AWS infrastructure and handles database credentials, so things
worth reporting include exposed secrets, insecure defaults, or anything that would let an
unintended party reach the database or the EC2 instances.

Note that the environment is meant for testing and deliberately serves the Adminer database
tool on the webserver — that's a known property of the demo, not a vulnerability in itself.
