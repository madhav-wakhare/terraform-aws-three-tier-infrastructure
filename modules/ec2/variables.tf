variable "environment" {
  description = "Environment in which resources are to be created"
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to attach Internet Gateway and NAT Gateway"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "private_security_group_id" {
  description = "Security Group ID for private EC2 instances"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security Group ID for bastion EC2 instance"
  type        = string
}

variable "bastion_public_keys" {
  description = "List of public keys for bastion host"
  type        = string
}

variable "private_ec2_public_keys" {
  description = "Public key for private EC2 instance"
  type        = string
}