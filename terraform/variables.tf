variable "vpc" {
  type        = string
  description = "The VPC to use for your instances"
}

variable "subnet" {
  type        = string
  description = "The subnet to use for your instances"
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