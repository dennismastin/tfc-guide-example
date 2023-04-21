output "instance_ami" {
  value = aws_instance.ubuntu.ami
}

output "instance_arn" {
  value = aws_instance.ubuntu.arn
}

output "instance_ipaddr" {
  value = aws_instance.ubuntu.public_ip
}

output "instance_ssh_private" {
  value = key_pair.private_key_pem
}

