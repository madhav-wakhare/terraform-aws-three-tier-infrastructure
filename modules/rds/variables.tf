variable "environment" {
  description = "Environment in which resources are to be created"
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to attach Internet Gateway and NAT Gateway"
}

variable "rds_security_group_id" {
  description = "Security Group ID for RDS instance"
  type        = string
}

variable "db_instance_class" {
  description = "RDS DB Instance Class"
  type        = string
}

variable "db_engine" {
  description = "RDS DB Engine"
  type        = string
}

variable "db_name" {
  description = "Name of the database to create when the DB instance is created"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for the RDS instance"
  type        = number
}

variable "db_storage_type" {
  description = "Storage type for the RDS instance (e.g., 'gp2', 'io1')"
  type        = string
}

variable "db_multi_az" {
  description = "Whether to create a Multi-AZ RDS instance"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups for the RDS instance"
  type        = number
  default     = 7
}

variable "db_engine_version" {
  description = "Version of the RDS DB engine (e.g., '13.4' for PostgreSQL)"
  type        = string
}

variable "rds_subnet_group_name" {
  description = "Name of the RDS subnet group to use for the RDS instance"
  type        = string
}

variable "backup_window" {
  description = "Preferred backup window for the RDS instance (e.g., '03:00-04:00')"
  type        = string
  default     = "03:00-04:00"
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage in GB for the RDS instance, it allows the RDS instance to automatically scale up storage when needed"
  type        = number
  default     = 1000
}

variable "rds_subnet_ids" {
  description = "List of RDS subnet IDs"
  type        = list(string)
}
