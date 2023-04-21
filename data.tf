data "template_file" "user_data" {
  template = file("${path.module}/user_data.tftpl")
  vars = {
    TEMPLATE_FLOWS_ADMIN_PWD = var.FLOWS_ADMIN_PWD
    SSH_PKEY = module.key_pair.private_key_pem
    SSH_ADDRESS = aws_instance.ubuntu.public_ip
    
  }
}
