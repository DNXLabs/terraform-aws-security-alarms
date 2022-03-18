resource "aws_cloudwatch_event_rule" "alarm_notification" {
  name        = "cloudtrail_alarm_custom_notifications"
  description = "Will be notified with a custom message when any alarm is performed"
  is_enabled = true

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
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.alarm_notification.name
  target_id = "NotifyLambda"
  arn       = aws_lambda_function.lambda.arn
}
