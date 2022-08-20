variable "ami_name" {
  type    = string
  default = "learn-packer-linux-aws"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "aws_access_key" {
 default = "{{env `AWS_ACCESS_KEY_ID`}}"
}  

variable "aws_secret_key"{
  default = "{{env `AWS_SECRET_ACCESS_KEY`}}"
}


variable "region" {
  type    = string
  #default = "{{env `AWS_REGION`}}"
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "ubuntu-eks/k8s_1.22/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  #ami-0a081d122468dc794"
  #"ubuntu-eks/k8s_1.20/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220623"
  #default = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
}



