resource "aws_sns_topic" "quote_topic" {
  name = "quotes"
}

# resource "aws_sns_topic_subscription" "notifications_sqs_target" {
#   topic_arn = aws_sns_topic.quote_topic.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.terraform_notifications_queue.arn
# }
