
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

# deploy lambda edge
module "lambda_edge_auth" {
  source        = "./modules/lambda-edge-auth"
  function_name = "lambda_basic_auth_${var.env}"
}

# deploy S3 buckets, CDN & DNS
module "webapp_s3_bucket_distribution" {
  source                    = "./modules/aws-web-distribution"
  env                       = var.env
  domain_name               = var.domain_name
  www_domain_name           = var.www_domain_name
  acm_certificate_arn       = var.acm_certificate_arn
  static_bucket_name        = "danielbot-epilot-static"
  spa_bucket_name           = "danielbot-epilot-spa"
  cdn_logging_bucket_name   = "danielbot-epilot-cdn-logging"
  logging_bucket_name       = "danielbot-epilot-s3-buckets-logging"
  origin_force_destroy      = false
  lambda_auth_qualified_arn = module.lambda_edge_auth.qualified_arn
}

# deploy spa & static files to S3
resource "null_resource" "upload_spa_files_to_s3" {
  provisioner "local-exec" {
    # use output from module
    command = "AWS_PRFOFILE=${var.profile} aws s3 sync ${path.module}/assets/spa s3://${module.webapp_s3_bucket_distribution.spa_bucket_id}"
  }
}

resource "null_resource" "upload_static_files_to_s3" {
  provisioner "local-exec" {
    # use output from module
    command = "AWS_PRFOFILE=${var.profile} aws s3 sync ${path.module}/assets/static s3://${module.webapp_s3_bucket_distribution.static_bucket_id}/static"
  }
}