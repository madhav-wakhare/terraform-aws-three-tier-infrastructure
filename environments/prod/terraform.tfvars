aws_region               = "us-east-2"          # Production runs in us-east-2
vpc_cidr_block           = "10.2.0.0/16"
instance_type            = "t3.medium"
allowed_ssh_cidr         = ["152.58.30.98/32"]   # Restrict to specific IPs in production

acm_certificate_arn      = "arn:aws:acm:us-east-2:<ACCOUNT_ID>:certificate/<CERT_ID>"  # TODO: replace with us-east-2 cert ARN
target_port              = 80

bastion_public_keys      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkCCIvROQDdh2TCKHPDj2jEnVXYyCE1NrMvj2pcb1hS madhav@DESKTOP-SMQ18V9"
private_ec2_public_keys  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkCCIvROQDdh2TCKHPDj2jEnVXYyCE1NrMvj2pcb1hS madhav@DESKTOP-SMQ18V9"

# ASG — scaled for production traffic
asg_min_size             = 2
asg_max_size             = 6
asg_desired_capacity     = 3

# db_username and db_password are read from AWS Secrets Manager (wg/prod/rds) — see secrets.tf
db_name                  = "wgproddb"
db_allocated_storage     = 50
db_max_allocated_storage = 1000
db_instance_class        = "db.t3.medium"
db_engine                = "mysql"
db_engine_version        = "8.0"
db_storage_type          = "gp2"
db_multi_az              = true       # High availability for production
backup_retention_period  = 14         # Longer retention for production
