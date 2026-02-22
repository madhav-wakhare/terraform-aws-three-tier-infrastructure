variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "bastion_allowed_ports" {
  type        = list(number)
  description = "Ports allowed into bastion from trusted CIDRs"
  default     = [22]
}

variable "allowed_ssh_cidr" {
  type        = list(string)
  description = "Trusted CIDR blocks allowed to SSH into the bastion host"
}

variable "allowed_app_ports" {
  type        = list(number)
  description = "Ports allowed into application servers from bastion"
  default     = [22, 80, 443]
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN for ALB HTTPS listener"
  type        = string
}

variable "target_port" {
  description = "Port on which the target is listening"
  type        = number
  default     = 80
}

variable "bastion_public_keys" {
  description = "Public key content for bastion host key pair"
  type        = string
}

variable "private_ec2_public_keys" {
  description = "Public key content for private EC2 / ASG key pair"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS database (in GB)"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "Instance class for RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "db_engine" {
  description = "Database engine for RDS instance"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Version of the RDS database engine"
  type        = string
  default     = "8.0"
}

variable "db_multi_az" {
  description = "Whether to create a Multi-AZ RDS instance"
  type        = bool
  default     = false
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for RDS database (in GB)"
  type        = number
  default     = 1000
}

variable "backup_retention_period" {
  description = "Number of days to retain backups for the RDS instance"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window for the RDS instance (e.g., '03:00-04:00')"
  type        = string
  default     = "03:00-04:00"
}

variable "db_storage_type" {
  description = "Storage type for the RDS instance (e.g., 'gp2', 'io1')"
  type        = string
  default     = "gp2"
}
