provider "aws" {
  profile = "aw-test"
  region  = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aw-test-vpc" 
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "aw-test-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "aw-test-public-rt"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.aws_availability_zone

  tags = {
    Name = "aw-test-public-subnet"
  }
}

# Associate route table to public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "aw-test-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "aw-test-ec2-role" 
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Launch Configuration 
resource "aws_launch_configuration" "lc" {
  name_prefix = "aw-test-"
  key_name = var.key_pair_name
  image_id = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  security_groups      = [aws_security_group.asg_sg.id]
  iam_instance_profile = "ec2-profile"
   user_data            = <<-EOF
    #!/bin/bash
    echo "Custom user data script"
    echo "Setting instance name..."
    echo "InstanceName=${var.instance_name}" >> /etc/environment
    echo "InstanceName=${var.instance_name}" >> /home/ubuntu/.bashrc
  EOF


  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "asg_sg" {
    name        = "asg-security-group"
    vpc_id = aws_vpc.main.id
    description = "Security group for ASG instances"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_ip]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                 = "aw-test-asg"
  launch_configuration = aws_launch_configuration.lc.name
  vpc_zone_identifier  = [aws_subnet.public.id]

  min_size = var.min_size
  max_size = var.max_size  

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }
}

# Scheduled Actions
resource "aws_autoscaling_schedule" "nightly" {
  scheduled_action_name  = "nightly"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 19 * * 1-5"

  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_schedule" "weekend" {
  scheduled_action_name  = "weekend"
  min_size               = 0 
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 7 * * 6,7"

  autoscaling_group_name = aws_autoscaling_group.asg.name
}

