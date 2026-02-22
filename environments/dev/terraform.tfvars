aws_region               = "ap-south-1"
vpc_cidr_block           = "10.0.0.0/16"
instance_type            = "t2.micro"
allowed_ssh_cidr         = ["49.36.44.240/32"]

acm_certificate_arn      = "arn:aws:acm:ap-south-1:429219760907:certificate/40629cd2-63e1-41d3-b804-87a86d65c2a5"
target_port              = 80

bastion_public_keys      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkCCIvROQDdh2TCKHPDj2jEnVXYyCE1NrMvj2pcb1hS madhav@DESKTOP-SMQ18V9"
private_ec2_public_keys  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkCCIvROQDdh2TCKHPDj2jEnVXYyCE1NrMvj2pcb1hS madhav@DESKTOP-SMQ18V9"

# ASG — small for dev
asg_min_size             = 1
asg_max_size             = 2
asg_desired_capacity     = 1

# db_username and db_password are read from AWS Secrets Manager (wg/dev/rds) — see secrets.tf
db_name                  = "wgdevdb"
db_allocated_storage     = 20
db_max_allocated_storage = 100
db_instance_class        = "db.t3.micro"
db_engine                = "mysql"
db_engine_version        = "8.0"
db_storage_type          = "gp2"
db_multi_az              = false
backup_retention_period  = 7
