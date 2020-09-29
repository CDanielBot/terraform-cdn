variable "env" {
  type        = string
  description = "The name of the environment"
  default     = "dev"
}

variable "domain_name" {
  type        = string
  description = "Domain name of the web app"
}

variable "www_domain_name" {
  type        = string
  description = "WWW Domain name of the web app"
}

variable "static_bucket_name" {
  type        = string
  description = "S3 bucket to hold the static assetsS"
}

variable "spa_bucket_name" {
  type        = string
  description = "S3 bucket to hold the SPA"
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
}

variable "origin_force_destroy" {
  type        = bool
  description = "Should delete all objects from the bucket so that the bucket can be destroyed without error (e.g. `true` or `false`)"
  default     = false
}

variable "lambda_auth_qualified_arn" {
    type = string
    description = "Qualified ARN of the lambda edge that performs basic authentication"
}