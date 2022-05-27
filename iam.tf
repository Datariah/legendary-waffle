resource "aws_iam_role" "lambda_exec" {
  name = "example-todos-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


# SQS Access

data "aws_iam_policy_document" "allow_sqs" {
  # Same as arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:TagQueue",
      "sqs:UntagQueue",
      "sqs:PurgeQueue",
      "sqs:GetQueueUrl"
    ]
    resources = [
      aws_sqs_queue.terraform_queue.arn,
    ]
  }
}

resource "aws_iam_policy" "allow_sqs" {
  name   = "allow-sqs"
  policy = data.aws_iam_policy_document.allow_sqs.json
}

resource "aws_iam_role_policy_attachment" "allow_sqs_from_lambda" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.allow_sqs.arn
}

# SNS Access
data "aws_iam_policy_document" "allow_sns" {
  # Same as arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:ListTagsForResource",
      "sns:ListSubscriptionsByTopic"
    ]
    resources = [
      aws_sns_topic.quote_topic.arn
    ]
  }
}

resource "aws_iam_policy" "allow_sns" {
  name   = "allow-sns"
  policy = data.aws_iam_policy_document.allow_sns.json
}

resource "aws_iam_role_policy_attachment" "allow_sns_from_lambda" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.allow_sns.arn
}



#
# Basic Execution role attachment
resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

