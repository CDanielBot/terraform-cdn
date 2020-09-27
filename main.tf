
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.aws_region
}

#-------------------------------------------------------------------------------------------
#                Bucket for logs: other S3 buckets will log here
#-------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.logging_bucket_name
  acl    = "log-delivery-write"
}

#-------------------------------------------------------------------------------------------
#                Bucket for static assets
#-------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "static_bucket" {
  bucket        = var.static_bucket_name
  acl           = "private"
  force_destroy = var.origin_force_destroy

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "static-bucket-logs/"
  }
}

#-------------------------------------------------------------------------------------------
#                Bucket for SPA web app
#-------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "spa_bucket" {
  bucket        = var.spa_bucket_name
  acl           = "private"
  force_destroy = var.origin_force_destroy

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "spa-bucket-logs/"
  }
}

#-------------------------------------------------------------------------------------------
#                OAI
#-------------------------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_identity" "danielbot_web_OAI" {
}

#-------------------------------------------------------------------------------------------
#               Policy Def & Attach for static bucket
#-------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "static_policy_OAI" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.danielbot_web_OAI.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.static_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "static_policy_attach" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.static_policy_OAI.json
}

#-------------------------------------------------------------------------------------------
#               Policy Def & Attach for SPA bucket
#-------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "spa_policy_OAI" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.danielbot_web_OAI.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.spa_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "spa_policy_attach" {
  bucket = aws_s3_bucket.spa_bucket.id
  policy = data.aws_iam_policy_document.spa_policy_OAI.json
}

#-------------------------------------------------------------------------------------------
#               Bucket, Policy Def & Attach for CDN logging bucket
#-------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "cdn_logging_bucket" {
  bucket        = var.cdn_logging_bucket_name
  acl           = "log-delivery-write"
  force_destroy = var.origin_force_destroy

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

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
  function_name    = "lambda_edge_authorizer"
  role             = aws_iam_role.lambda_edge_exec.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  publish          = true
  provider         = aws.us_east_1
}

#-------------------------------------------------------------------------------------------
#               locals
#-------------------------------------------------------------------------------------------
locals {
  static_origin_id = "static_origin"
  spa_origin_id    = "spa_origin"
}

#-------------------------------------------------------------------------------------------
#               CloudFront distribution for both static assets and SPA web app
#-------------------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "web_distribution" {
  enabled             = true
  is_ipv6_enabled     = false # to allow ip restrictions as per AWS docs
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  # bucket logging
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cdn_logging_bucket.bucket_domain_name
  }

  # Origin Def for static assets
  origin {
    domain_name = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    origin_id   = local.static_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.danielbot_web_OAI.cloudfront_access_identity_path
    }
  }

  # Origin Def for SPA assets
  origin {
    domain_name = aws_s3_bucket.spa_bucket.bucket_regional_domain_name
    origin_id   = local.spa_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.danielbot_web_OAI.cloudfront_access_identity_path
    }
  }

  # Default cache: serve SPA web app
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.spa_origin_id

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    # Add lambda edge for authentication
    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.lambda_edge_auth.qualified_arn
    }
  }

  # Ordered cache: serve static assets for static/* path
  ordered_cache_behavior {
    path_pattern     = "static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.static_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  aliases = [var.domain_name, var.www_domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["DE", "RO"]
    }
  }

  tags = {
    Environment = var.env
  }

  # Use the ACM certificate validated for the domain
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

}

#-------------------------------------------------------------------------------------------
#               DNS setup
#-------------------------------------------------------------------------------------------
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.www_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.web_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}