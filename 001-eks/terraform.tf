terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
    time = {
      source  = "hashicorp/time"
    }
  }
}

data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN
