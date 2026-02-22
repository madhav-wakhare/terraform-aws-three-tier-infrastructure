resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default" # Default instance tenancy means instances can be launched with shared tenancy, Tenancy means instances launched in this VPC will run on dedicated hardware

  tags = {
    Name = "wg-${var.environment}-vpc"
  }
}

# Retrieve available availability zones in the region
data "aws_availability_zones" "available_azs" {
  state = "available" # Filter to get only available zones
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id  = aws_vpc.main_vpc.id
  cidr_block  = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index) # Create a subnet with a /24 CIDR block within the VPC's /16 CIDR block
  availability_zone = data.aws_availability_zones.available_azs.names[count.index] # Specify the availability zone based on the count index, it will create 2 public subnets in different AZs
  map_public_ip_on_launch = true # Automatically assign public IPs to instances launched in this subnet

  tags = {
    Name = "wg-${var.environment}-public_subnet-${count.index+1}"
    Tier = "public"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.main_vpc.id
  availability_zone = data.aws_availability_zones.available_azs.names[count.index] # Specify the availability zone based on the count index, it will create 2 private subnets in different AZs
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index + 10) # Create a subnet with a /24 CIDR block within the VPC's /16 CIDR block, starting from a different range than public subnets, 10 here comes as 10.0.10.0/24 & 10.0.11.0/24
  map_public_ip_on_launch = false # Do not automatically assign public IPs to instances launched in this subnet, as private subnets should not have public IPs

  tags = {
    Name = "wg-${var.environment}-private_subnet-${count.index+1}"
    Tier = "private"
  }
}

# Create RDS Subnets in different availability zones for high availability and fault tolerance of RDS instances
resource "aws_subnet" "rds_subnet" {
  count = 2
  vpc_id = aws_vpc.main_vpc.id
  availability_zone = data.aws_availability_zones.available_azs.names[count.index] # Specify the availability zone based on the count index, it will create 2 RDS subnets in different AZs
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index + 20) # Create a subnet with a /24 CIDR block within the VPC's /16 CIDR block, starting from a different range than public and private subnets, 20 here comes as 10.0.20.0/24 & 10.0.21.0/24
  map_public_ip_on_launch = false # Do not automatically assign public IPs to instances launched in this subnet, as RDS subnets should be private

  tags = {
    Name = "wg-${var.environment}-rds_subnet-${count.index+1}"
    Tier = "rds"
  }
}

# Create a DB Subnet Group for RDS to specify which subnets RDS instances can be launched in because RDS instances need to be launched in a DB subnet group which is a collection of subnets that you can designate for your RDS DB instances in a VPC, it allows you to specify which subnets RDS instances can be launched in, and it also provides high availability and failover support for RDS instances by allowing you to specify multiple subnets in different availability zones.
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "wg-${var.environment}-rds-subnet-group"
  subnet_ids = aws_subnet.rds_subnet[*].id # Using splat operator to get all RDS subnet IDs

  tags = {
    Name = "wg-${var.environment}-rds-subnet-group"
  }
}