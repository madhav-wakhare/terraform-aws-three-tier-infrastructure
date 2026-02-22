resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "internet-gateway-${var.environment}-${var.vpc_id}"
  }
}

# Attach the Internet Gateway to the VPC
resource "aws_internet_gateway_attachment" "main_vpc_attachment" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = var.vpc_id
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain   = "vpc" # Allocate EIP for NAT Gateway in VPC

  tags = {
    Name = "nat-elastic-ip-${var.environment}-${var.vpc_id}"
  }
}

# NAT Gateway Resource
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_ids[0] # Creating NAT Gateway in the first public subnet

  tags = {
    Name = "nat-gateway-${var.environment}-${var.vpc_id}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

