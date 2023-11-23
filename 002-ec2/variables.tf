variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/20"
} 

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"  
  type        = string
  default     = "10.0.1.0/24"
}


variable "aws_availability_zone" {
  default = "us-east-1a"
}

variable "ami_id" {
  description = "ec2-ami"
  type        = string
  default     = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number  
  default     = "1"
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default      = "1"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "aw-test-eks"
}

variable "key_pair_name" {
  description = "Name of the key pair"
  type        = string
  default     = "aw-test"
}

variable "allowed_ssh_ip" {
  description = "Allowed SSH IP address"
  type        = string
  default     = "31.15.24.51/32" 
}
