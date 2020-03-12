##########
# THANOS #
##########

# Kubernetes Secret holding thanos configuration file
resource "kubernetes_secret" "thanos_config" {
  count      = var.enable_thanos ? 1 : 0

  metadata {
    name      = "thanos-objstore-config"
    namespace = kubernetes_namespace.monitoring.id
  }

  data = {
    "thanos.yaml"       = file("${path.module}/templates/thanos-objstore-config.yaml.tpl")
    "object-store.yaml" = file("${path.module}/templates/thanos-objstore-config.yaml.tpl")
  }

  type = "Opaque"
}

# Thanos Helm Chart

resource "helm_release" "thanos" {
  count      = var.enable_thanos ? 1 : 0

  name      = "thanos"
  namespace = kubernetes_namespace.monitoring.id
  chart     = "banzaicloud-stable/thanos"
  version   = "0.3.18"

  values = [templatefile("${path.module}/templates/thanos-values.yaml.tpl", {
    enabled_compact        = var.enable_thanos_compact
    monitoring_aws_role    = aws_iam_role.monitoring.0.name
  })]

  depends_on = [ helm_release.prometheus_operator ]

  lifecycle {
    ignore_changes = [keyring]
  }
}
