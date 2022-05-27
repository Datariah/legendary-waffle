resource "aws_lambda_function" "quote_generator" {
  function_name = "quote-generator"

  s3_bucket = aws_s3_bucket.lambdas.id
  s3_key    = aws_s3_object.lambda_binaries.key

  runtime = "go1.x"
  handler = "generator"

  source_code_hash = data.archive_file.lambda_binaries.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      SQS_QUEUE_NAME = aws_sqs_queue.terraform_queue.name
      SQS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    }
  }
}

resource "aws_lambda_function" "quote_receiver" {
  function_name = "quote-receiver"

  s3_bucket = aws_s3_bucket.lambdas.id
  s3_key    = aws_s3_object.lambda_binaries.key

  runtime = "go1.x"
  handler = "receiver"

  source_code_hash = data.archive_file.lambda_binaries.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      SQS_QUEUE_NAME = aws_sqs_queue.terraform_queue.name
    }
  }
}

resource "aws_lambda_function" "quote_gateway" {
  function_name = "quote-gateway"

  s3_bucket = aws_s3_bucket.lambdas.id
  s3_key    = aws_s3_object.lambda_binaries.key

  runtime = "go1.x"
  handler = "gateway"

  source_code_hash = data.archive_file.lambda_binaries.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.quote_topic.arn
    }
  }
}

resource "aws_lambda_function" "quote_pusher" {
  function_name = "quote-pusher"

  s3_bucket = aws_s3_bucket.lambdas.id
  s3_key    = aws_s3_object.lambda_binaries.key

  runtime = "go1.x"
  handler = "pusher"

  source_code_hash = data.archive_file.lambda_binaries.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      # Your bot token, should begin with xoxb-
      SLACK_BOT_TOKEN = "xoxb-paste-your-bot-token-here"
      SLACK_CHANNEL_ID = "channel-id-goes-here"
    }
  }
}

# Event source from SQS
resource "aws_lambda_event_source_mapping" "sqs_lambda" {
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.quote_gateway.arn
  batch_size       = 1
}

resource "aws_sns_topic_subscription" "sns_quote_pusher" {
  endpoint  = aws_lambda_function.quote_pusher.arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.quote_topic.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quote_pusher.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.quote_topic.arn
}
