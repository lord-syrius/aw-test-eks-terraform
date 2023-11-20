cluster_name            = "aw-eks-test-localstack"
iac_environment_tag     = "development"
name_prefix             = "aw-test"
main_network_block      = "10.0.0.0/16"
cluster_azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
subnet_prefix_extension = 4
zone_offset             = 8
#eks_managed_node_groups = "default"
eks_managed_node_groups = {
  default = {
    min_size = 1
    max_size = 5
    desired_size = 3
    instance_type = "t3.medium"
  }
}
autoscaling_average_cpu = 70
spot_termination_handler_chart_name = "spot-termination-handler"
spot_termination_handler_chart_repo = "stable"
spot_termination_handler_chart_version = "1.0.0"
spot_termination_handler_chart_namespace = "default"
dns_base_domain = "mydomain.com"
ingress_gateway_name = "my-ingress-gateway"
ingress_gateway_iam_role = "my-ingress-gateway-role"
ingress_gateway_chart_name = "ingress-nginx"
ingress_gateway_chart_repo = "stable"
ingress_gateway_chart_version = "3.0.0"
external_dns_iam_role = "my-external-dns-role"
external_dns_chart_name = "external-dns"
external_dns_chart_repo = "stable"
external_dns_chart_version = "2.0.0"
#external_dns_values = "{\"provider\": \"aws\"}"
external_dns_values = {
  provider = "aws"
}
namespaces = ["namespace1", "namespace2"]
admin_users = ["admin1", "admin2"]  
developer_users = ["developer1", "developer2"]  
