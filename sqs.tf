resource "aws_sqs_queue" "terraform_queue" {
  name                      = "event-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.terraform_queue_deadletter.arn}\",\"maxReceiveCount\":4}"
}

resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name                      = "dead-letter-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

# See https://docs.aws.amazon.com/sns/latest/dg/subscribe-sqs-queue-to-sns-topic.html
data "aws_iam_policy_document" "allow_sns_ingestion" {
  statement {
    sid     = "SNSIngrestion01"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    # We need to use this to avoid a circular dependency in terraform
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.notification_resources_prefix}-queue"]

    condition {
      test = "ArnEquals"
      values = [
        aws_sns_topic.quote_topic.arn
      ]
      variable = "aws:SourceArn"
    }
  }
}
