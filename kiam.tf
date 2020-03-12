######################
# Grafana Cloudwatch #
######################

# Grafana datasource for cloudwatch
# Ref: https://github.com/helm/charts/blob/master/stable/grafana/values.yaml

data "aws_iam_policy_document" "grafana_datasource_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "grafana_datasource" {
  name               = "datasource.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.grafana_datasource_assume.json
}

# Minimal policy permissions 
# Ref: https://grafana.com/docs/grafana/latest/features/datasources/cloudwatch/#iam-policies

data "aws_iam_policy_document" "grafana_datasource" {
  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.grafana_datasource.arn]
  }
}

resource "aws_iam_role_policy" "grafana_datasource" {
  name   = "grafana-datasource"
  role   = aws_iam_role.grafana_datasource.id
  policy = data.aws_iam_policy_document.grafana_datasource.json
}

################
# ECR Exporter #
################

data "aws_iam_policy_document" "ecr_exporter_assume" {
  count     = var.enable_ecr_exporter ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "ecr_exporter" {
  count     = var.enable_ecr_exporter ? 1 : 0

  name               = "ecr-exporter.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.ecr_exporter_assume.0.json
}

data "aws_iam_policy_document" "ecr_exporter" {
  count     = var.enable_ecr_exporter ? 1 : 0

  statement {
    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_exporter" {
  count     = var.enable_ecr_exporter ? 1 : 0

  name   = "ecr-exporter"
  role   = aws_iam_role.ecr_exporter.0.id
  policy = data.aws_iam_policy_document.ecr_exporter.0.json
}

#######################
# Cloudwatch Exporter #
#######################

# KIAM role creation
# Ref: https://github.com/helm/charts/blob/master/stable/prometheus-cloudwatch-exporter/values.yaml

data "aws_iam_policy_document" "cloudwatch_export_assume" {
  count     = var.enable_cloudwatch_exporter ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "cloudwatch_exporter" {
  count     = var.enable_cloudwatch_exporter ? 1 : 0

  name               = "cloudwatch.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_export_assume.0.json
}

data "aws_iam_policy_document" "cloudwatch_exporter" {
  count     = var.enable_cloudwatch_exporter ? 1 : 0

  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_exporter" {
  count     = var.enable_cloudwatch_exporter ? 1 : 0

  name   = "cloudwatch-exporter"
  role   = aws_iam_role.cloudwatch_exporter.0.id
  policy = data.aws_iam_policy_document.cloudwatch_exporter.0.json
}

##########
# THANOS #
##########

# This is to create a policy which allows Prometheus (thanos to be precise) to have a role to write to S3 without credentials
data "aws_iam_policy_document" "monitoring_assume" {
  count      = var.enable_thanos ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [ var.iam_role_nodes ]
    }
  }
}

resource "aws_iam_role" "monitoring" {
  count      = var.enable_thanos ? 1 : 0

  name               = "monitoring.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume.0.json
}

data "aws_iam_policy_document" "monitoring" {
  count      = var.enable_thanos ? 1 : 0

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject"
    ]

    # Bucket name is hardcoded because it hasn't been created with terraform
    # files inside this repository. Once we are happy with the test we must: 
    # 1. Create S3 bucket from the cp-environments repo (or maybe from here?)
    # 2. Use the output (S3 bucket name) in this policy
    resources = [
      "arn:aws:s3:::cloud-platform-prometheus-thanos/*",
      "arn:aws:s3:::cloud-platform-prometheus-thanos"
    ]
  }
}

resource "aws_iam_role_policy" "monitoring" {
  count      = var.enable_thanos ? 1 : 0

  name   = "route53"
  role   = aws_iam_role.monitoring.0.id
  policy = data.aws_iam_policy_document.monitoring.0.json
}

