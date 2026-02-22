output "bastion_ec2_instance_id" {
  value       = aws_instance.bastion_ec2.id
  description = "ID of the bastion EC2 instance"
}

# As ASG will be used to create private EC2 instances, we don't need to output the private EC2 instance IDs

# output "private_ec2_instance_id" {
#   value       = aws_instance.private_ec2.id
#   description = "ID of the private EC2 instance"
# }

# output "private_ec2_instances_list" {
#   value       = tolist(aws_instance.private_ec2.*.id) # Convert the list of private EC2 instance IDs to a list type
#   description = "List of private EC2 instance IDs"
# }