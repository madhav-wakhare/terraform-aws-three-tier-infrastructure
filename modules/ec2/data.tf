data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # Ubuntu 22.04 AMI name pattern
  }

  filter {
    name   = "virtualization-type" 
    values = ["hvm"] # Specifies the virtualization type
  }

  owners = ["099720109477"] # Canonical owner ID
}
