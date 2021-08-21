resource "random_string" "cloudtrail_alarm_suffix" {
  count   = var.enabled ? 1 : 0
  length  = 8
  special = false
  lower   = true
  upper   = false
  number  = false
}

resource "aws_cloudformation_stack" "cloudtrail_alarm" {
  count         = var.enabled ? 1 : 0
  name          = "cloudtrail-alarm-slack-${random_string.cloudtrail_alarm_suffix[0].result}"
  template_body = file("${path.module}/cloudtrail-alarms.cf.yml")

  parameters = {
    CloudTrailLogGroupName = var.cloudtrail_log_group_name
    AlarmNotificationTopic = aws_sns_topic.alarms[0].id
  }
}
