# --------------------------------------------------------------------------------------------------
# Variables for alarm-baseline module.
# --------------------------------------------------------------------------------------------------


variable "enable_alarm_baseline" {
  description = "The boolean flag whether this module is enabled or not. No resources are created when set to false."
  default     = true
}

variable "account_name" {
  description = "Name of this account to identify the alarms"
}

variable "alarm_namespace" {
  description = "The namespace in which all alarms are set up."
  default     = "CISBenchmark"
}

variable "alarm_sns_topic_name" {
  description = "The name of the SNS Topic which will be notified when any alarm is performed."
  default     = "CISAlarm"
}

variable "alarm_account_ids" {
  default     = []
  description = "AWS Account IDs to allow receiving alarms to the SNS Topic"
}

variable "cloudtrail_log_group_name" {
  description = "The name of Cloudtrail log group. (Default is <org-name>-cloudtrail)"
  default     = ""
}

locals {
  cloudtrail_log_group_name = var.cloudtrail_log_group_name == "" ? "${var.org_name}-cloudtrail" : var.cloudtrail_log_group_name
}

variable "tags" {
  description = "Specifies object tags key and value. This applies to all resources created by this module."
  default = {
    "Terraform" = true
  }
}
# --------------------------------------------------------------------------------------------------
# Variables for chatbot notifications.
# --------------------------------------------------------------------------------------------------
variable "org_name" {
  description = "Name for this organization"
}
variable "enable_chatbot_slack" {
  description = "If true, will create aws chatboot and integrate to slack"
  default     = true
}
variable "slack_channel_id" {
  description = "Slack channel id to send budget notification using AWS Chatbot"
  default     = ""
}
variable "slack_workspace_id" {
  description = "Slack workspace id to send budget notification using AWS Chatbot"
  default     = ""
}
