# --------------------------------------------------------------------------------------------------
# The SNS topic to which CloudWatch alarms send events.
# --------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "alarms" {
  count             = var.enabled ? 1 : 0
  name              = var.sns_topic_name
  kms_master_key_id = aws_kms_key.sns[0].id # default key does not allow cloudwatch alarms to publish
  tags              = var.tags
}

data "aws_iam_policy_document" "kms_policy_sns" {
  count = var.enabled ? 1 : 0
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    actions = ["kms:Decrypt", "kms:GenerateDataKey*"]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    resources = ["*"]
    sid       = "allow-cloudwatch-kms"
  }
}

resource "aws_kms_key" "sns" {
  count                   = var.enabled ? 1 : 0
  deletion_window_in_days = 7
  description             = "SNS CMK Encryption Key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy_sns[0].json
}

resource "aws_sns_topic_policy" "alarms" {
  count  = var.enabled ? 1 : 0
  arn    = aws_sns_topic.alarms[0].arn
  policy = data.aws_iam_policy_document.alarms_policy[0].json
}

data "aws_iam_policy_document" "alarms_policy" {
  count     = var.enabled ? 1 : 0
  policy_id = "allow-org-accounts"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = var.alarm_account_ids
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.alarms[0].arn,
    ]
    sid = "allow-org-accounts"
  }
}
