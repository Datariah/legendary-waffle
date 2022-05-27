resource "aws_cloudwatch_log_group" "quote_generator" {
  name = "/aws/lambda/${aws_lambda_function.quote_generator.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "quote_receiver" {
  name = "/aws/lambda/${aws_lambda_function.quote_receiver.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "quote_gateway" {
  name = "/aws/lambda/${aws_lambda_function.quote_gateway.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "quote_pusher" {
  name = "/aws/lambda/${aws_lambda_function.quote_pusher.function_name}"

  retention_in_days = 30
}
