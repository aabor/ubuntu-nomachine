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

resource "aws_instance" "nomachine" {
  ami                         = "ami-079a547fc5d4eb0d3"
  #t2.medium 2/4/5,  c6a.xlarge 4/8/12.5/0.153 USD per Hour, t3.xlarge 4vcpu/ 16 Gb/ up to 5 Gigabit/ 0.1664 USD per Hour
  instance_type               = "t3.xlarge"
  vpc_security_group_ids      = [aws_security_group.ssh.id, aws_security_group.nomachine.id]
  associate_public_ip_address = true

  tags = {
    Name = "aabor@ubuntu-nomachine"
  }
}

output "public_ip" {
  value = aws_instance.nomachine.public_ip
}
