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

variable "static_bucket_name" {
  type        = string
  description = "S3 bucket to hold the SPA"
  default     = "danielbot-epilot-static"
}

variable "spa_bucket_name" {
  type        = string
  description = "S3 bucket to hold the SPA"
  default     = "danielbot-epilot-spa"
}

variable "origin_force_destroy" {
  type        = bool
  description = "Should delete all objects from the bucket so that the bucket can be destroyed without error (e.g. `true` or `false`)"
  default     = false
}