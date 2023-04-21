provider "conjur" {}

#hello david test 4-21

data "conjur_secret" "aws_access_key_id" {
  name = "data/vault/ussewest-rsa/Cloud Service-AWSProgrammaticAccessKeys-dennis.mastin/AWSAccessKeyID"
}

data "conjur_secret" "aws_secret_key" {
  name = "data/vault/ussewest-rsa/Cloud Service-AWSProgrammaticAccessKeys-dennis.mastin/password"
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

variable "FLOWS_ADMIN_PWD" {
  description = "Flows admin user"
  default     = ""
}

