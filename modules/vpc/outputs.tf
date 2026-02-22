output "vpc_id" {
  value = aws_vpc.main_vpc.id # Output the ID of the main VPC
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id # Using splat operator to output all public subnet IDs
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id # Using splat operator to output all private subnet IDs
}

output "rds_subnet_ids" {
  value = aws_subnet.rds_subnet[*].id # Using splat operator to output all RDS subnet IDs
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name # Output the name of the RDS subnet group
}