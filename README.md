# Learn Terraform Provisioning

This repo is a companion repo to the [Learn Terraform Provisioning](https://developer.hashicorp.com/terraform/tutorials/provision/packer) tutorial.
It contains Terraform configuration you can use to learn how to provision Terraform instances with Packer.

```sh
# manually create some resources and import it, if needed
aws ec2 create-security-group \
  --group-name nomachine \
  --description "Remote desktop nomachine, NX protocol" \
  --vpc-id vpc-3039a858
# GroupId: sg-02504e1b0bf59dda8

# NX nomachine
aws ec2 authorize-security-group-ingress \
  --group-id sg-02504e1b0bf59dda8 \
  --protocol tcp \
  --port 4000 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-02504e1b0bf59dda8 \
  --protocol udp \
  --port 4011-4999 \
  --cidr 0.0.0.0/0
terraform import aws_security_group.nomachine sg-02504e1b0bf59dda8

```

```sh
cd instances
terraform output -raw public_ip
# 3.144.11.236%  
ssh 3.144.11.236
sudo nano /usr/NX/etc/server.cfg
sudo /etc/NX/nxserver --restart
sudo netstat -tunlp | grep nxd

```
