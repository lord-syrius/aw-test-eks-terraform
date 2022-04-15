# create some variables
variable "admin_users" {
  type        = list(string)
  description = "List of Kubernetes admins."
}
variable "developer_users" {
  type        = list(string)
  description = "List of Kubernetes developers."
}
variable "asg_instance_types" {
  type        = list(string)
  description = "List of EC2 instance machine types to be used in EKS."
}
variable "autoscaling_minimum_size_by_az" {
  type        = number
  description = "Minimum number of EC2 instances to autoscale our EKS cluster on each AZ."
}
variable "autoscaling_maximum_size_by_az" {
  type        = number
  description = "Maximum number of EC2 instances to autoscale our EKS cluster on each AZ."
}
variable "autoscaling_average_cpu" {
  type        = number
  description = "Average CPU threshold to autoscale EKS EC2 instances."
}
variable "spot_termination_handler_chart_name" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "spot_termination_handler_chart_repo" {
  type        = string
  description = "EKS Spot termination handler Helm repository name."
}
variable "spot_termination_handler_chart_version" {
  type        = string
  description = "EKS Spot termination handler Helm chart version."
}
variable "spot_termination_handler_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
}

# render Admin & Developer users list with the structure required by EKS module
locals {
  admin_user_map_users = [
    for admin_user in var.admin_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
      username = admin_user
      groups   = ["system:masters"]
    }
  ]
  developer_user_map_users = [
    for developer_user in var.developer_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${developer_user}"
      username = developer_user
      groups   = ["${var.name_prefix}-developers"]
    }
  ]
}

# create EKS cluster
module "eks-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.19.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    eks = {
      min_size       = var.autoscaling_minimum_size_by_az * length(data.aws_availability_zones.available_azs.zone_ids)
      max_size       = var.autoscaling_maximum_size_by_az * length(data.aws_availability_zones.available_azs.zone_ids)
      desired_size   = var.autoscaling_minimum_size_by_az * length(data.aws_availability_zones.available_azs.zone_ids)
      instance_types = var.asg_instance_types
      capacity_type  = "SPOT"
      network_interfaces = [{
        delete_on_termination = true
      }]
    }
  }
}

# # map developer & admin ARNs as kubernetes Users
# module "eks-cluster-auth" {
#   source  = "aidanmelen/eks-auth/aws"
#   version = "~> 0.9.0"
#
#   eks       = module.eks-cluster
#   map_users = concat(local.admin_user_map_users, local.developer_user_map_users)
# }

# add spot fleet Autoscaling policy
resource "aws_autoscaling_policy" "eks_autoscaling_policy" {
  count = length(module.eks-cluster.eks_managed_node_groups_autoscaling_group_names)

  name                   = "${module.eks-cluster.eks_managed_node_groups_autoscaling_group_names[count.index]}-autoscaling-policy"
  autoscaling_group_name = module.eks-cluster.eks_managed_node_groups_autoscaling_group_names[count.index]
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.autoscaling_average_cpu
  }
}

# # get EKS cluster info to configure Kubernetes and Helm providers
# data "aws_eks_cluster" "cluster" {
#   name = module.eks-cluster.cluster_id
# }
# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks-cluster.cluster_id
# }
#
# # get EKS authentication for being able to manage k8s objects from terraform
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   load_config_file       = false
#   version                = "~> 1.9"
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#     load_config_file       = false
#   }
#   version = "~> 1.2"
# }
#
# # deploy spot termination handler
# resource "helm_release" "spot_termination_handler" {
#   name       = var.spot_termination_handler_chart_name
#   chart      = var.spot_termination_handler_chart_name
#   repository = var.spot_termination_handler_chart_repo
#   version    = var.spot_termination_handler_chart_version
#   namespace  = var.spot_termination_handler_chart_namespace
# }
#
