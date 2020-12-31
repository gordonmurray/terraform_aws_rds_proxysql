variable "vpc" {
  type        = string
  description = "The VPC to use for your instances"
}

variable "subnets" {
  type        = list
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