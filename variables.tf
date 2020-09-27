variable "profile" {
  type        = string
  description = "AWS profile to be used by terraform when running commands"
  default     = "default"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to create the resources in."
  default     = "eu-west-1"
}

variable "env" {
  type        = string
  description = "The name of the environment"
  default     = "dev"
}

variable "domain_name" {
  type        = string
  description = "Domain name of the web app"
  default     = "danielbot-epilot.ml"
}

variable "www_domain_name" {
  type        = string
  description = "WWW Domain name of the web app"
  default     = "www.danielbot-epilot.ml"
}

variable "static_bucket_name" {
  type        = string
  description = "S3 bucket to hold the static assetsS"
  default     = "danielbot-epilot-static"
}

variable "spa_bucket_name" {
  type        = string
  description = "S3 bucket to hold the SPA"
  default     = "danielbot-epilot-spa"
}

variable "cdn_logging_bucket_name" {
  type        = string
  description = "S3 bucket to hold the CDN logging"
  default     = "danielbot-epilot-cdn-logging"
}

variable "logging_bucket_name" {
  type        = string
  description = "S3 bucket to hold the S3 buckets logging"
  default     = "danielbot-epilot-s3-buckets-logging"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM Certificate to be used for Cloudfront & DNS setup"
  default     = "arn:aws:acm:us-east-1:028723015732:certificate/df12c875-9de6-45d8-9c7d-e6a376361200"
}

variable "origin_force_destroy" {
  type        = bool
  description = "Should delete all objects from the bucket so that the bucket can be destroyed without error (e.g. `true` or `false`)"
  default     = false
}