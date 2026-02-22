# ALB Resource
resource "aws_lb" "alb" {
  name               = "wg-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application" 
  security_groups    = [var.alb_security_group_id] # Attach the ALB security group to the ALB, security_groups takes a list
  subnets            = [for subnet in var.public_subnet_ids : subnet] # Attach ALB to all public subnets

  enable_deletion_protection = false # Enable deletion protection for ALB

  tags = {
    Name = "wg-${var.environment}-alb"
  }
}

# Application Load Balancer Target Group Resource to forward traffic to private EC2 instances
resource "aws_lb_target_group" "alb_target_group" {
    name     = "wg-${var.environment}-alb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id # Attach to the VPC
    target_type = "instance" # Forwarding to EC2 instances

    health_check {
        healthy_threshold   = 3  # Number of consecutive health checks successes required before considering an unhealthy target healthy
        unhealthy_threshold = 3  # Number of consecutive health check failures required before considering a target unhealthy
        timeout             = 5
        interval            = 30
        path                = "/"       # Health check path
        matcher             = "200-399" # Consider HTTP 2xx and 3xx as healthy
    }
    
    tags = {
        Name = "wg-${var.environment}-alb-tg"
    }
}

# ALB HTTP Listener Resource to redirect HTTP traffic to HTTPS
resource "aws_lb_listener" "http_to_https_port_listener" {
  load_balancer_arn = aws_lb.alb.arn # Attach to the ALB created above
  port              = "80"           # HTTP port
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "redirect" # Redirect HTTP to HTTPS
    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"
    }
  }
}

# ALB HTTPS Listener Resource with SSL Termination and forwarding traffic to the target group with 443 port
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # SSL policy for the listener
  certificate_arn   = var.acm_certificate_arn # ACM Certificate ARN for SSL termination
  default_action {
    type             = "forward"  # Forward traffic to target group
    target_group_arn = aws_lb_target_group.alb_target_group.arn # Forward to the target group created above
  }
}

# As ASG will be used to create private EC2 instances, we need to attach them to the target group
# The instances will be registered with the target group automatically when they are created by the ASG

# # Application Load Balancer Target Group Attachment Resource to attach private EC2 instances to the target group
# resource "aws_lb_target_group_attachment" "alb_targets" {
#   # for_each needs its keys to be known at plan time but count does NOT. So can't use for_each here.
#   count = length(var.private_ec2_instances_list) # Number of private EC2 instances to attach to the target group
#   target_group_arn = aws_lb_target_group.alb_target_group.arn
#   target_id        = var.private_ec2_instances_list[count.index] # Use the instance ID from the list
#   port             = var.target_port # Port on which the target is listening
# }

