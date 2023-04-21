provider "aws" {
  access_key = data.conjur_secret.aws_access_key_id.value
  secret_key = data.conjur_secret.aws_secret_key.value
  region     = var.region
}

# Sxxxxx 
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  user_data     = data.template_file.user_data.rendered
  key_name      = module.key_pair.key_pair_name

  tags = {
    Name = var.instance_name
  }
}

module "key_pair" { 
  source = "terraform-aws-modules/key-pair/aws" 
  key_name = "dam-rsa2023-tf-keypair" 
  create_private_key = true
  private_key_rsa_bits = 2048
}
  
  