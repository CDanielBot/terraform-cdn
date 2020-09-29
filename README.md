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

* `domain_name`: *Mandatory* - Domain name of the web app.

* `www_domain_name`: *Mandatory* - www Domain name of the web app.

* `static_bucket_name`: *Optional* - S3 bucket to hold the static assets. Default: danielbot-epilot-static

* `spa_bucket_name`: *Optional* - S3 bucket to hold the SPA web app. Default: danielbot-epilot-spa

* `cdn_logging_bucket_name`: *Optional* - S3 bucket to hold the CDN logging. Default: danielbot-epilot-cdn-logging

* `logging_bucket_name`: *Optional* - S3 bucket to hold the S3 buckets logging. Default: danielbot-epilot-s3-buckets-logging

* `acm_certificate_arn`: *Mandatory* - ARN of the ACM Certificate to be used for Cloudfront & DNS setup.

* `origin_force_destroy`: *Optional* - Should delete all objects from the bucket so that the bucket can be destroyed without error. Default: false


# Run

1. terraform init

2. terraform import module.webapp_s3_bucket_distribution.aws_acm_certificate.cert <cert_arn> 

3. terraform plan -out tf.plan

4. terraform apply tf.plan

# Destroy infrastructure

1. terraform destroy

# Improvements roadmap

1. Add rewriting rule for URLs without "www" prefix.

2. Make buckets names dependent on env. Eg: dev/staging/prod envs can follow the same naming structure, but suffixed with env name. (DONE)

3. Keep lambda code for authorization / static files / SPA web files in separate repos. (as an automation workaround they are kept in this repo)

4. Split root module into child module and call it. (DONE)

5. Push tags to all terraform managed resources.

6. Consider KMS key instead of AES256 for buckets encryption