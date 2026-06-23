variable "vpc" {
  type        = string
  description = "The VPC to use for your instances"
}

variable "subnets" {
  type        = list(any)
  description = "The subnets available in the VPC"
}

variable "my_ip_address" {
  type        = string
  description = "Current IP Address to allow SSH access"
}

variable "ami" {
  type        = string
  default     = "ami-0aef57767f5404a3c"
  description = "The AMI to use for the EC2 instances"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key to register as the EC2 key pair (e.g. ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub)"
}