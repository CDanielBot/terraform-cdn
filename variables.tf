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

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM Certificate to be used for Cloudfront & DNS setup"
}