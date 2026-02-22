variable "environment" {
  description = "Environment in which resources are to be created"
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to attach Internet Gateway and NAT Gateway"
}

variable "bastion_allowed_ports" {
  type        = list(number)
  description = "Ports allowed into bastion from trusted CIDRs"
  default     = [22]
}

variable "allowed_ssh_cidr" {
  type = list(string)
}

variable "allowed_app_ports" {
  type        = list(number)
  description = "Ports allowed into application servers from bastion"
  default     = [80, 443, 22]
}

variable "allowed_alb_ports" {
  type        = list(number)
  description = "Ports allowed for ALB to access application servers"
  default     = [80, 443]
}

variable "allowed_rds_ports" {
  type        = list(number)
  description = "Ports allowed for application servers to access RDS instances"
  default     = [3306]
  
}