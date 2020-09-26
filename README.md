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


