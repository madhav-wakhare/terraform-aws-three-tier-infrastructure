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

variable "private_security_group_id" {
  description = "Security Group ID for private EC2 instances"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security Group ID for bastion EC2 instance"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security Group ID for ALB"
  type        = string
}

# variable "private_ec2_instances_list" {
#   description = "List of private EC2 instance IDs for ALB target group"
#   type        = list(string)
# }

variable "acm_certificate_arn" {
  type = string
}

variable "target_port" {
  description = "Port on which the target is listening"
  type        = number
  default     = 80
}
