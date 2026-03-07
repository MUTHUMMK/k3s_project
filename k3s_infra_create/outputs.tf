output "aws_instance" {
  description = "to get the publice IP ADDRESS"
  value = aws_instance.k3s_server.public_ip
}