output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_id" {
  value = aws_lb.alb.id
  description = "ID of the Application Load Balancer"
}

output "alb_target_group_arn" {
  value       = aws_lb_target_group.alb_target_group.arn
  description = "ARN of the Application Load Balancer Target Group"
}

