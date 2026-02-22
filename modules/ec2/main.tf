# Create a Key Pair for Bastion Host
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key-${var.environment}"
  public_key = var.bastion_public_keys # Path to the public key file

  tags = {
    Name = "wg-${var.environment}-bastion-key"
  }
}

resource "aws_key_pair" "private_key" {
  key_name   = "private-key-${var.environment}"
  public_key = var.private_ec2_public_keys # Path to the public key file
  tags = {
    Name = "wg-${var.environment}-private-key"
  }
}

# Bastion EC2 Instance Resource
resource "aws_instance" "bastion_ec2" {
  ami           = data.aws_ami.ubuntu.id # Using the Ubuntu AMI fetched from data source
  instance_type = var.instance_type 

  subnet_id = var.public_subnet_ids[0] # Associating bastion host with the first public subnet
  associate_public_ip_address = true # Bastion host needs a public IP to allow SSH access
  vpc_security_group_ids = [var.bastion_security_group_id] # Attach the bastion security group, vpc security group ids takes a list

  key_name = aws_key_pair.bastion_key.key_name # Associate the key pair created for bastion host

  tags = {
    Name = "wg-${var.environment}-bastion-ec2"
  }
}


# Commented out as ASG will be used to create private EC2 instances

# # Private EC2 Instance Resource
# resource "aws_instance" "private_ec2" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.instance_type

#   subnet_id = var.private_subnet_ids[0] # Associating private host with the first private subnet
#   associate_public_ip_address = false # Private host does not need a public IP address
#   vpc_security_group_ids = [var.private_security_group_id] # Attach the private security group, vpc security group ids takes a list

#     key_name = aws_key_pair.private_key.key_name # Associate the key pair created for private host

#   tags = {
#     Name = "wg-${var.environment}-private-ec2"
#   }
# }

