module "vpc" {
  source         = "../../modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  environment    = "dev"
}

module "gateways" {
  source            = "../../modules/gateways"
  environment       = "dev"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "route_tables" {
  source              = "../../modules/route_tables"
  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  internet_gateway_id = module.gateways.internet_gateway_id
  nat_gateway_id      = module.gateways.nat_gateway_id
  rds_subnet_ids      = module.vpc.rds_subnet_ids
}

module "sg" {
  source                = "../../modules/sg"
  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  allowed_ssh_cidr      = var.allowed_ssh_cidr
  bastion_allowed_ports = var.bastion_allowed_ports
}

module "ec2" {
  source                    = "../../modules/ec2"
  environment               = "dev"
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  bastion_security_group_id = module.sg.bastion_security_group_id
  private_security_group_id = module.sg.private_security_group_id
  instance_type             = var.instance_type
  bastion_public_keys       = var.bastion_public_keys
  private_ec2_public_keys   = var.private_ec2_public_keys
}

module "alb" {
  source                    = "../../modules/alb"
  environment               = "dev"
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  bastion_security_group_id = module.sg.bastion_security_group_id
  private_security_group_id = module.sg.private_security_group_id
  alb_security_group_id     = module.sg.alb_security_group_id
  acm_certificate_arn       = var.acm_certificate_arn
  target_port               = var.target_port
}

module "asg" {
  source                    = "../../modules/asg"
  environment               = "dev"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  private_security_group_id = module.sg.private_security_group_id
  instance_type             = var.instance_type
  asg_min_size              = var.asg_min_size
  asg_max_size              = var.asg_max_size
  asg_desired_capacity      = var.asg_desired_capacity
  alb_target_group_arn      = module.alb.alb_target_group_arn
  acm_certificate_arn       = var.acm_certificate_arn
  public_subnet_ids         = module.vpc.public_subnet_ids
  bastion_security_group_id = module.sg.bastion_security_group_id
  private_ec2_public_keys   = var.private_ec2_public_keys
  alb_security_group_id     = module.sg.alb_security_group_id
}

module "rds" {
  source                    = "../../modules/rds"
  environment               = "dev"
  vpc_id                    = module.vpc.vpc_id
  rds_security_group_id     = module.sg.rds_security_group_id
  rds_subnet_group_name     = module.vpc.rds_subnet_group_name
  rds_subnet_ids            = module.vpc.rds_subnet_ids
  db_username               = local.db_username # sourced from AWS Secrets Manager via secrets.tf
  db_password               = local.db_password # sourced from AWS Secrets Manager via secrets.tf
  db_allocated_storage      = var.db_allocated_storage
  db_instance_class         = var.db_instance_class
  db_engine                 = var.db_engine
  db_engine_version         = var.db_engine_version
  db_max_allocated_storage  = var.db_max_allocated_storage
  db_multi_az               = var.db_multi_az
  backup_retention_period   = var.backup_retention_period
  db_storage_type           = var.db_storage_type
  db_name                   = var.db_name
}
