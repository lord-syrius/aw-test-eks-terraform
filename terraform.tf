terraform {
  required_version = "1.1.9"

  backend "s3" {}

  required_providers {
    aws = {
      version = "~> 4.9.0" # which means ">= 4.9.0" and "< 4.10"
    }
    kubernetes = {
      version = "~> 2.10.0"
    }
    helm = {
      version = "~> 2.5.1"
    }
  }
}

data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN
