output "vpc_id" {
  description = "ID of the prod VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the prod Application Load Balancer"
  value       = module.alb.alb_dns_name
}
