
variable "alertmanager_slack_receivers" {
  description = "A list of configuration values for Slack receivers"
  type        = list
}

variable "iam_role_nodes" {
  description = "Nodes IAM role ARN in order to create the KIAM/Kube2IAM"
  type        = string
}

variable "pagerduty_config" {
  description = "Add PagerDuty key to allow integration with a PD service."
}

variable "dependence_deploy" {
  description = "Deploy Module dependences in order to be executed."
}

variable "dependence_opa" {
  description = "OPA module dependences in order to be executed."
}

variable "enable_ecr_exporter" {
  description = "Enable or not ECR exporter"
  default     = false
  type        = bool
}

variable "enable_thanos" {
  description = "Enable or not Thanos"
  default     = true
  type        = bool
}

variable "enable_cloudwatch_exporter" {
  description = "Enable or not Cloudwatch exporter"
  default     = false
  type        = bool
}

variable "enable_thanos_compact" {
  description = "Enable or not Thanos Compact - not semantically concurrency safe and must be deployed as a singleton against a bucket"
  default     = false
  type        = bool
}

variable "running_in_eks" {
  description = "If this module is being deployed in EKS the paths for states are different, the IAM policies too. We need to know against what is running"
  default     = false
  type        = bool
}
