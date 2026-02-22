variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment in which resources are to be created"
  type = string
}