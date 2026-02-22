resource "aws_db_instance" "rds_instance" {
  identifier = "wg-${var.environment}-rds-instance"
  publicly_accessible = false # RDS instance should not be publicly accessible, it will be accessed through the private EC2 instances in the private subnets
  storage_encrypted = true # Enable storage encryption for the RDS instance at rest
  skip_final_snapshot = false # Create a final snapshot before deleting the RDS instance, set to false to avoid accidental deletion without a backup
  final_snapshot_identifier = "wg-${var.environment}-rds-instance-final-snapshot" # Identifier for the final snapshot created when the RDS instance is deleted, it should be unique and descriptive
  engine = var.db_engine                   # Database engine (e.g., 'mysql', 'postgres', 'oracle-se2', etc.)
  engine_version = var.db_engine_version   # Version of the database engine (e.g., '13.4' for PostgreSQL)
  instance_class = var.db_instance_class   # RDS DB instance class (e.g., 'db.t3.micro', 'db.m5.large', etc.)
  allocated_storage = var.db_allocated_storage  # Allocated storage in GB for the RDS instance
  storage_type = var.db_storage_type         # Storage type for the RDS instance (e.g., 'gp2', 'io1')
  db_name = var.db_name                      # Name of the database to create when the DB instance is created
  username = var.db_username                 # Master username for the RDS instance
  password = var.db_password                 # Master password for the RDS instance
  vpc_security_group_ids = [var.rds_security_group_id] # Attach the RDS security group, vpc security group means it takes a list of security group ids
  db_subnet_group_name = var.rds_subnet_group_name # Subnet group for the RDS instance, it should be created in the VPC module and passed as a variable to this module
  multi_az = var.db_multi_az # Whether to create a Multi-AZ RDS instance, default is false
  backup_retention_period = var.backup_retention_period # Number of days to retain backups for the RDS instance, default is 7
  backup_window = var.backup_window # Preferred backup window for the RDS instance (e.g., '03:00-04:00')
  apply_immediately = true # Apply changes immediately, set to true for development and testing environments, set to false for production environments to avoid downtime during maintenance
  max_allocated_storage = var.db_max_allocated_storage # Maximum allocated storage in GB for the RDS instance, it allows the RDS instance to automatically scale up storage when needed, default is 1000 GB

  tags = {
    Name = "wg-${var.environment}-rds-instance"
  }
}


