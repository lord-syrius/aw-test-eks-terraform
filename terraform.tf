terraform {
  required_version = ">= 1.4.6"

  backend "s3" {
    bucket         = "test-aw-lstack-aws-nonprod-tf-states-critical"
    key            = "test-aw-lstack-aws-nonprod-account.terraform.tfstates"
    encrypt        = true
    region         = "us-east-1"
    dynamodb_table = "test-aws-lstack-nonprod-tf-locks-critical"
    profile        = "aw-test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation = true
    skip_requesting_account_id = true
    skip_get_ec2_platforms = true

  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.65.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.9.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.9.1"
    }
  }
}

data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN

provider "aws" {
  default_tags {
    tags = {
      iac_environment = var.iac_environment_tag
    }
  }
}
