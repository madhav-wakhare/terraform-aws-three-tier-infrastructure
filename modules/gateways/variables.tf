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
