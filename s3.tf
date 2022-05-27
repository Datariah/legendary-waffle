resource "aws_s3_bucket" "lambdas" {
  bucket = "datariah-lambda-functions"

  force_destroy = true
}

data "archive_file" "lambda_binaries" {
  type = "zip"

  source_dir  = "${path.module}/bin"
  output_path = "${path.module}/event-binaries.zip"

}

resource "aws_s3_object" "lambda_binaries" {
  bucket = aws_s3_bucket.lambdas.id

  key    = "event-binaries.zip"
  source = data.archive_file.lambda_binaries.output_path

  source_hash = filemd5(data.archive_file.lambda_binaries.output_path)
}


