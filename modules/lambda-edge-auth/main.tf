#-------------------------------------------------------------------------------------------
#               Lambda edge for CloudFront authentication with BasicAuth 
#-------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_edge_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_edge_exec.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Lambda edge must be deploy to us-east-1 to work
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda/index.js"
  output_path = "lambda/lambda_auth.zip"
}

resource "aws_lambda_function" "lambda_edge_auth" {
  filename         = "lambda/lambda_auth.zip"
  function_name    = var.function_name
  role             = aws_iam_role.lambda_edge_exec.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  publish          = true
  provider         = aws.us_east_1
}