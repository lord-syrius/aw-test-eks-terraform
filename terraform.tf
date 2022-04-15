terraform {
  required_version = "~> 1.1.8" # which means ">= 1.1.8" and "< 1.2"

  backend "s3" {}

  required_providers {
    aws = {
      version = "~> 4.9.0"
    }
    random = {
      version = "~> 3.1.2"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = "~> 2.4.1"
    }
  }
}

data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN
