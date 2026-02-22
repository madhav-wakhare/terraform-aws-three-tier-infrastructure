# Register the public key in AWS EC2 so the launch template can reference it by name.
# key_name expects the NAME of an EC2 key pair, not the raw key content.
resource "aws_key_pair" "private_ec2_key_pair" {
  key_name   = "wg-${var.environment}-private-ec2-key"
  public_key = var.private_ec2_public_keys
}

# Acts as a blueprint for your EC2 instances. It defines the AMI, instance type, key pair, network interfaces (with your private_security_group_id), and user data (startup scripts).
resource "aws_launch_template" "launch_template" {
  name_prefix   = "wg-${var.environment}-launchTemplate" # Name prefix means that the actual name will have a random suffix appended to it, ensuring uniqueness.
  image_id      = data.aws_ami.ubuntu.id # The ID of the AMI to use for the instances. This is retrieved from the data source defined in data.tf, which filters for the latest Ubuntu 22.04 AMI.
  instance_type = var.instance_type # The type of instance to launch, specified as a variable for flexibility.
  key_name      = aws_key_pair.private_ec2_key_pair.key_name # Reference the registered key pair name

  vpc_security_group_ids = [
    var.private_security_group_id # Security Group ID for private EC2 instances launched by ASG
  ]

  metadata_options {
    http_tokens = "required" # Require IMDSv2 for enhanced security
  }

  # Tag specifications to apply tags to instances launched from this template. This helps in identifying and managing resources in AWS.
  tag_specifications {
    resource_type = "instance" # Specifies that the tags defined in this block should be applied to EC2 instances launched from this template

    tags = {
      Name = "wg-${var.environment}-asg-ec2" # Tag to identify instances launched from this template
    }
  }
}



# Manages the collection of EC2 instances. It uses the Launch Template to provision instances into your private_subnet_ids. Here you define the min_size, max_size, and desired_capacity
resource "aws_autoscaling_group" "private_asg" {
  launch_template {
    id      = aws_launch_template.launch_template.id # Reference to the launch template created above
    version = "$Latest"
  }
  vpc_zone_identifier  = var.private_subnet_ids   # List of private subnet IDs where the ASG will launch instances
  min_size             = var.asg_min_size         # Minimum number of instances in the Auto Scaling Group
  max_size             = var.asg_max_size         # Maximum number of instances in the Auto Scaling Group
  desired_capacity     = var.asg_desired_capacity # Desired number of instances to maintain in the Auto Scaling Group 

  lifecycle {
    create_before_destroy = true # Ensures that a new ASG is created before the old one is destroyed during updates, preventing downtime.
  }
  
  tag {
    key = "Name"
    value = "wg-${var.environment}-private-asg"
    propagate_at_launch = true
  }
}


# Automatically registers the instances created by the ASG with your Application Load Balancer (ALB) Target Group.
resource "aws_autoscaling_attachment" "asg_alb_attachment" {
  autoscaling_group_name = aws_autoscaling_group.private_asg.name # Reference to the Auto Scaling Group created above
  lb_target_group_arn    = var.alb_target_group_arn # Reference to the ALB Target Group created in the alb module
}

# Defines scaling policies (e.g., Target Tracking Scaling to dynamically add/remove instances if CPU utilization goes above/below a certain threshold).
resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "asg-target-tracking-${var.environment}"
  autoscaling_group_name = aws_autoscaling_group.private_asg.name  # Reference to the Auto Scaling Group created above
  policy_type            = "TargetTrackingScaling"  # Specifies that this is a target tracking scaling policy, which adjusts the number of instances in the ASG to maintain a specified metric at a target value.

  # Target tracking configuration to maintain average CPU utilization at 60%. AWS will automatically add or remove instances in the ASG to keep the average CPU utilization near this target.
  target_tracking_configuration {          
    predefined_metric_specification {      
      predefined_metric_type = "ASGAverageCPUUtilization" # Use average CPU utilization across the ASG as the metric for scaling
    }
    target_value = 60.0  # AWS will keep average CPU near 60%
  }
}
