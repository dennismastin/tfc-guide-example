provider "conjur" {}

data "conjur_secret" "aws_access_key_id" {
  name = "aws-access-key"
}

data "conjur_secret" "aws_secret_key" {
  name = "aws-secret-key"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  default = "${data.conjur_secret.aws_access_key_id.value}"
}

variable "aws_secret_key" {
  description = "AWS Access Key ID"
  default = "${data.conjur_secret.aws_secret_key.value}"
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

