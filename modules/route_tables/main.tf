# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  # Add route for Internet Gateway
  route {
    cidr_block = "0.0.0.0/0" # Route for all IPv4 traffic through Internet Gateway
    gateway_id = var.internet_gateway_id # Internet Gateway as the target
  }

  tags = {
    Name = "wg-${var.environment}-public-route-table"
  }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  # Add route for NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0" # Route for all IPv4 traffic through NAT Gateway
    nat_gateway_id = var.nat_gateway_id # NAT Gateway as the target
  }
    tags = {
        Name = "wg-${var.environment}-private-route-table"
    }
}

# Subnet Associations
# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
    count          = length(var.public_subnet_ids) # Number of public subnets
    subnet_id      = var.public_subnet_ids[count.index] # Associating each public subnet
    route_table_id = aws_route_table.public_route_table.id # with the public route table
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
    count          = length(var.private_subnet_ids) # Number of private subnets
    subnet_id      = var.private_subnet_ids[count.index] # Associating each private subnet
    route_table_id = aws_route_table.private_route_table.id # with the private route table
}

# RDS Route Table for RDS subnets, it will not have any routes because RDS subnets are private and should not have a route to the Internet Gateway or NAT Gateway, it is just for better organization and management of RDS subnets
resource "aws_route_table" "rds_route_table" {
  vpc_id = var.vpc_id   # VPC ID to associate the route table with

  tags = {
    Name = "wg-${var.environment}-rds-route-table"
  }
}

# Associate RDS Subnets with RDS Route Table
resource "aws_route_table_association" "rds_subnet_association" {
    count          = length(var.rds_subnet_ids) # Number of RDS subnets
    subnet_id      = var.rds_subnet_ids[count.index] # Associating each RDS subnet
    route_table_id = aws_route_table.rds_route_table.id # with the RDS route table
}