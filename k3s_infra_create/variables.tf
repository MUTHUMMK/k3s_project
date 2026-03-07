variable "ami" {
  description = "select the ami id"
  default = "ami-019715e0d74f695be"
}

variable "instance_type" {
  description = "select the instance type"
  default = "t3.medium"
}

variable "key_name" {
  description = "select the .pem key"
  default = "test"
}

variable "server_name" {
  description = "server name"
  default = "K3S-SERVER"
}