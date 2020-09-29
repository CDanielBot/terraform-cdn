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
}

variable "www_domain_name" {
  type        = string
  description = "WWW Domain name of the web app"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM Certificate to be used for Cloudfront & DNS setup"
  default     = "arn:aws:acm:us-east-1:028723015732:certificate/df12c875-9de6-45d8-9c7d-e6a376361200"
}