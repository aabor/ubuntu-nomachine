variable "region" {
  type    = string
  default = "us-east-2"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "ubuntu" {
  ami_name              = "aabor@ubuntu-nomachine"
  instance_type         = "t2.medium"
  region                = var.region
  force_deregister      = true
  force_delete_snapshot = true
  ssh_username          = "ubuntu"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      state               = "available"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    OS_Version    = "Ubuntu"
    Release       = "20.04"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Extra         = "{{ .SourceAMITags.TagName }}"
    Timestamp     = local.timestamp
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ami_block_device_mappings {
    device_name  = "/dev/sdb"
    virtual_name = "ephemeral0"
  }
  ami_block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral1"
  }
}
# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "./id_rsa.pub"
    destination = "/tmp/id_rsa.pub"
  }
  provisioner "file" {
    source      = "./nx/server.cfg"
    destination = "/tmp/"
  }
  provisioner "file" {
    source      = "./deluge/core.conf"
    destination = "/tmp/"
  }
  provisioner "file" {
    source      = "./pgp_aws.pub"
    destination = "/tmp/"
  }  
  provisioner "shell" {
    script = "../scripts/setup.sh"
  }
}
