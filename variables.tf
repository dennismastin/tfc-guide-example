provider "conjur" {}

#hello david

data "conjur_secret" "aws_access_key_id" {
  name = "data/dev/aws-access-key"
}

data "conjur_secret" "aws_secret_key" {
  name = "data/dev/aws-secret-key"
}

variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  default     = "DAM 2 ussewest Provisioned by Terraform"
}

