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

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type = string
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID"
  type = string
}

variable "rds_subnet_ids" {
  description = "List of RDS subnet IDs"
  type        = list(string)
}