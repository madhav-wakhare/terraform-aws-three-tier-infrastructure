output "vpc_id" {
  description = "ID of the dev VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the dev Application Load Balancer"
  value       = module.alb.alb_dns_name
}
