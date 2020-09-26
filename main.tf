terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = var.profile #todo: change the default profile
  region  = var.aws_region
}

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
        sse_algorithm = "AES256" #consider using KMS key for encryption
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

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
        sse_algorithm = "AES256" #consider using KMS key for encryption
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "danielbot_web_OAI" {
}

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
  bucket = "${aws_s3_bucket.static_bucket.id}"
  policy = "${data.aws_iam_policy_document.static_policy_OAI.json}"
}

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
  bucket = "${aws_s3_bucket.spa_bucket.id}"
  policy = "${data.aws_iam_policy_document.spa_policy_OAI.json}"
}

locals {
  static_origin_id = "static_origin"
  spa_origin_id    = "spa_origin"
}

resource "aws_cloudfront_distribution" "web_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  origin {
    domain_name = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    origin_id   = local.static_origin_id

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.danielbot_web_OAI.cloudfront_access_identity_path}"
    }
  }

  origin {
    domain_name = aws_s3_bucket.spa_bucket.bucket_regional_domain_name
    origin_id   = local.spa_origin_id

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.danielbot_web_OAI.cloudfront_access_identity_path}"
    }
  }

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
  }

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

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["DE", "RO"]
    }
  }

  tags = {
    Environment = var.env
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_route53_zone" "primary" {
  name = var.domain_name
}