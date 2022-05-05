autoscaling_average_cpu = 30
eks_managed_node_groups = {
  "x86" = {
    ami_type     = "AL2_x86_64"
    min_size     = 1
    max_size     = 16
    desired_size = 1
    instance_types = [
      "t3.small",
      "t3.medium",
      "t3.large",
      "t3a.small",
      "t3a.medium",
      "t3a.large"
    ]
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = true
    }]
  }
  "arm" = {
    ami_type     = "AL2_ARM_64"
    min_size     = 1
    max_size     = 16
    desired_size = 1
    instance_types = [
      "c6g.medium",
      "c6g.large"
    ]
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = true
    }]
  }
}
