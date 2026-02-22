# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
    name        = "bastion-sg-${var.environment}"
    description = "Security group for bastion host"
    vpc_id      = var.vpc_id
    
    tags = {
      Name = "wg-${var.environment}-bastion-sg"
    }
}

# Security Group for Private EC2 Instances
resource "aws_security_group" "private_sg" {
    name        = "private-sg-${var.environment}"
    description = "Security group for private EC2 instances"
    vpc_id      = var.vpc_id
    
    tags = {
      Name = "wg-${var.environment}-private-sg"
    }
}

# Ingress Rules for Bastion Security Group
resource "aws_vpc_security_group_ingress_rule" "ingress_for_bastion" {
  for_each = toset(var.allowed_ssh_cidr) # Create a set of allowed SSH CIDRs
  
  security_group_id = aws_security_group.bastion_sg.id # Attached to bastion security group
  cidr_ipv4   = each.value # Source CIDR from the set
  from_port   = var.bastion_allowed_ports[0] # Assuming single port for SSH i.e port 22
  ip_protocol = "tcp"
  to_port     = var.bastion_allowed_ports[0] # Assuming single port for SSH i.e port 22
  description = "Allow SSH access from trusted CIDRs to bastion host"
}

# Ingress Rules for Private Security Group to allow traffic from Bastion
resource "aws_vpc_security_group_ingress_rule" "ingress_for_app_servers" {
  for_each = {
    for port in var.allowed_app_ports :  # Iterate over allowed application ports
    tostring(port) => port               # Create a map with port as key and value
  }

  security_group_id = aws_security_group.private_sg.id  # Attached to private security group
  referenced_security_group_id = aws_security_group.bastion_sg.id # Source is bastion security group i.e allow traffic from bastion host to private instances
  from_port   = each.value # Accessing port from the map
  ip_protocol = "tcp"
  to_port     = each.value # Accessing port from the map
  description = "Allow ${each.value} access from bastion host to private instances"
}

# Egress Rules for Bastion Security Group to allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "egress_from_bastion" {
  security_group_id = aws_security_group.bastion_sg.id # Attached to bastion security group
  cidr_ipv4         = "0.0.0.0/0" # Allow all outbound traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
  description = "Allow all outbound traffic from bastion host"
}

# Egress Rules for Private Security Group to allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "egress_from_private" {
  security_group_id = aws_security_group.private_sg.id # Attached to private security group
  cidr_ipv4         = "0.0.0.0/0" # Allow all outbound traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
  description = "Allow all outbound traffic from private instances"
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
    name        = "alb-sg-${var.environment}"
    description = "Security group for Application Load Balancer"
    vpc_id      = var.vpc_id # Attach to VPC
    
    tags = {
      Name = "wg-${var.environment}-alb-sg"
    }
}

# Ingress Rules for ALB Security Group to allow traffic for Private Instances
resource "aws_vpc_security_group_ingress_rule" "alb_ingress" {
  for_each = {
    for port in var.allowed_alb_ports :  # Iterate over allowed ALB ports
    tostring(port) => port               # Create a map with port as key and value
  }

  cidr_ipv4         = "0.0.0.0/0" # Allow access from anywhere
  security_group_id = aws_security_group.alb_sg.id # Attached to ALB security group
  from_port   = each.value # Accessing port from the map
  ip_protocol = "tcp"
  to_port     = each.value # Accessing port from the map
  description = "Allow ${each.value} access to ALB from anywhere"
}

# Egress Rules for ALB Security Group to allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb_sg.id # Attached to ALB security group
  cidr_ipv4         = "0.0.0.0/0" # Allow all outbound traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
  description = "Allow all outbound traffic from ALB"
}

# Security Group for RDS Instances
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg-${var.environment}"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id  # Attach to VPC                       

  tags = {
    Name = "wg-${var.environment}-rds-sg"
  }
}

# Ingress Rules for RDS Security Group to allow traffic from Private Instances
resource "aws_vpc_security_group_ingress_rule" "rds_ingress" {
  for_each = {
    for port in var.allowed_rds_ports :  # Iterate over allowed RDS ports
    tostring(port) => port               # Create a map with port as key and value
  }

  security_group_id = aws_security_group.rds_sg.id # Attached to RDS security group
  referenced_security_group_id = aws_security_group.private_sg.id # Source is private security group i.e allow traffic from private instances to RDS instances
  from_port   = each.value # Accessing port from the map
  ip_protocol = "tcp"
  to_port     = each.value # Accessing port from the map
  description = "Allow ${each.value} access from private instances to RDS instances"
}

# Egress Rules for RDS Security Group to allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "rds_egress" {
  security_group_id = aws_security_group.rds_sg.id # Attached to RDS security group
  cidr_ipv4         = "0.0.0.0/0" # Allow all outbound traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
  description = "Allow all outbound traffic from RDS instances"
}