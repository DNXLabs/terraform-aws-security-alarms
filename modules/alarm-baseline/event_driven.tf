resource "aws_cloudwatch_event_rule" "alarm_notification" {
  name        = "daily_enforce_bucket_kms_encryption"
  description = "run everyday"
  is_enabled = false

  event_pattern = <<PATTERN
  {
    "source": [
        "aws.cloudwatch"
    ],
    "detail-type": [
        "CloudWatch Alarm State Change"
    ],
    "detail": {
        "state": {
            "value": [
                "ALARM"
            ]
        }
    }
  }
  PATTERN
}
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.alarm_notification.name
  target_id = "NotifyLambda"
  arn       = aws_sns_topic.aws_logins.arn
}
