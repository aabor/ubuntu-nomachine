# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
  }
  required_version = ">= 0.14.5"
}
provider "aws" {
  region = var.region
}
resource "aws_security_group" "nomachine" {
  name        = "nomachine"
  description = "Remote desktop nomachine, NX protocol"
  ingress {
    description = "TCP port where the NX service is listening"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "UDP port where the NX service is listening"
    from_port   = 4000
    to_port     = 4000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port range, in the form of minport-maxport, to use UDP communication for multimedia data"
    from_port   = 4011
    to_port     = 4999
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "SSH access from the VPC"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ebs_volume" "vms" {
  availability_zone = var.availability_zone
  size              = 40
  tags = {
    Name = "vms"
  }
}
resource "aws_volume_attachment" "vms" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.vms.id
  instance_id = aws_instance.nomachine.id
  skip_destroy = false
}
resource "aws_instance" "nomachine" {
  ami               = "ami-031c0eac039043a2e"
  availability_zone = var.availability_zone
  #t2.medium 2/4/5,  c6a.xlarge 4/8/12.5/0.153 USD per Hour, t3.xlarge 4vcpu/ 16 Gb/ up to 5 Gigabit/ 0.1664 USD per Hour
  # "t3.xlarge"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.ssh.id, aws_security_group.nomachine.id]
  associate_public_ip_address = true
  tags = {
    Name = "aabor@ubuntu-nomachine"
  }
}

output "public_ip" {
  value = aws_instance.nomachine.public_ip
}
output "vms_volume_id" {
  value = aws_ebs_volume.vms.id
}
