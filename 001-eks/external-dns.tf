# create some variables
variable "external_dns_iam_role" {
  type        = string
  description = "IAM Role Name associated with external-dns service."
}
variable "external_dns_chart_name" {
  type        = string
  description = "Chart Name associated with external-dns service."
}

variable "external_dns_chart_repo" {
  type        = string
  description = "Chart Repo associated with external-dns service."
}

variable "external_dns_chart_version" {
  type        = string
  description = "Chart Repo associated with external-dns service."
}

variable "external_dns_values" {
  type        = map(string)
  description = "Values map required by external-dns service."
}

# deploy 'external-dns' service
resource "helm_release" "external_dns" {
  name       = var.external_dns_chart_name
  chart      = var.external_dns_chart_name
  repository = var.external_dns_chart_repo
  version    = var.external_dns_chart_version
  namespace  = "kube-system"

  dynamic "set" {
    for_each = var.external_dns_values

    content {
      name  = set.key
      value = set.value
      type  = "string"
    }
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.external_dns_iam_role}"
  }

  set {
    name  = "domainFilters"
    value = "{${var.dns_base_domain}}"
  }

  set {
    name  = "txtOwnerId"
    value = aws_route53_zone.base_domain.zone_id
  }
}
