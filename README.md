# General

<h3> Terraform module for deploying: </h3>

1. DNS zone & records based on ACM certificate ARN

2. CDN for static assets and SPA web app

3. Separate S3 buckets for static assets and SPA web app

4. Logging buckets

# Setup

Make sure you have these tools previously installed on your machine:
* AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
* Terraform - https://learn.hashicorp.com/tutorials/terraform/install-cli
* 

Also make sure you have an AWS account setup, with default profile configured as well (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). 


# Variables

* `profile`: *Required* - AWS CLI profile to be used. TODO: chande from default

* `aws_region`: *Required* - The AWS region used for creating the terraform resources.

* `environment_name`: *Required* - The name of the environment that the module is used for. The name of the IAM resources will be derived from this.


# Run

1. terraform init

2. terraform plan -out tf.plan

3. terraform apply tf.plan

# Destroy infrastructure

1. terraform destroy

# Improvements roadmap

1. Consider KMS key instead of AES256 for buckets encryption