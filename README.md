# General

<h3> Terraform module for deploying: </h3>

1. DNS zone & records based on ACM certificate ARN

2. CDN for static assets and SPA web app

3. Separate S3 buckets for static assets and SPA web app

4. Logging buckets


# Demo showcase

Deploying with the default variable setup, will make public the following URLs:

* https://www.danielbot-epilot.ml   - for SPA webapp
* https://www.danielbot-epilot.ml/static/*   - for static files (eg: https://www.danielbot-epilot.ml/static/epilot.jpg )

# Setup

Make sure you have these tools previously installed on your machine:
* AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
* Terraform - https://learn.hashicorp.com/tutorials/terraform/install-cli


Also make sure you have an AWS account setup, with default profile configured as well (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). 


# Variables

* `profile`: *Optional* - AWS CLI profile to be used. Default: default

* `aws_region`: *Optional* - The AWS region used for creating the terraform resources. Default: eu-west-1

* `env`: *Optional* - The name of the environment that the module is used for. The name of the IAM resources will be derived from this.

* `domain_name`: *Optional* - Domain name of the web app. Default: danielbot-epilot.ml

* `www_domain_name`: *Optional* - www Domain name of the web app. Default: www.danielbot-epilot.ml

* `static_bucket_name`: *Optional* - S3 bucket to hold the static assets. Default: danielbot-epilot-static

* `spa_bucket_name`: *Optional* - S3 bucket to hold the SPA web app. Default: danielbot-epilot-spa

* `cdn_logging_bucket_name`: *Optional* - S3 bucket to hold the CDN logging. Default: danielbot-epilot-cdn-logging

* `logging_bucket_name`: *Optional* - S3 bucket to hold the S3 buckets logging. Default: danielbot-epilot-s3-buckets-logging

* `acm_certificate_arn`: *Optional* - ARN of the ACM Certificate to be used for Cloudfront & DNS setup.

* `origin_force_destroy`: *Optional* - Should delete all objects from the bucket so that the bucket can be destroyed without error. Default: false


# Run

1. terraform init

2. terraform plan -out tf.plan

3. terraform apply tf.plan

# Destroy infrastructure

1. terraform destroy

# Improvements roadmap

1. Consider KMS key instead of AES256 for buckets encryption

2. Add rewriting rule for URLs without "www" prefix. Eg: https://danielbot-epilot.ml

3. Make variables mandatory & add validations. Right now all variables have default values just for the sake of being easy to setup.

4. Make buckets names dependent on env. Eg: dev/staging/prod envs can follow the same naming structure, but prefixed with env name. 