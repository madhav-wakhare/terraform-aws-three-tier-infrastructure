output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id
  description = "value of bastion security group ID"
}

output "private_security_group_id" {
  value = aws_security_group.private_sg.id
  description = "value of private security group ID"
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
  description = "value of ALB security group ID"
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
  description = "value of RDS security group ID"
}
