aws_region               = "ap-south-1"
vpc_cidr_block           = "10.1.0.0/16"
instance_type            = "t3.small"
allowed_ssh_cidr         = ["152.58.30.98/32"]

acm_certificate_arn      = "arn:aws:acm:ap-south-1:429219760907:certificate/40629cd2-63e1-41d3-b804-87a86d65c2a5"
target_port              = 80

bastion_public_keys      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkCCIvROQDdh2TCKHPDj2jEnVXYyCE1NrMvj2pcb1hS madhav@DESKTOP-SMQ18V9"
private_ec2_public_keys  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkCCIvROQDdh2TCKHPDj2jEnVXYyCE1NrMvj2pcb1hS madhav@DESKTOP-SMQ18V9"

# ASG — moderate for staging
asg_min_size             = 1
asg_max_size             = 3
asg_desired_capacity     = 2

# db_username and db_password are read from AWS Secrets Manager (wg/staging/rds) — see secrets.tf
db_name                  = "wgstagingdb"
db_allocated_storage     = 20
db_max_allocated_storage = 500
db_instance_class        = "db.t3.small"
db_engine                = "mysql"
db_engine_version        = "8.0"
db_storage_type          = "gp2"
db_multi_az              = false
backup_retention_period  = 7
