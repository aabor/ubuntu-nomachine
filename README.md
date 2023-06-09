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
terraform apply
# public_ip = "18.224.73.229"
# vms_volume_id = "vol-08d9e227b7e059de0"

terraform output -raw public_ip
# 3.144.11.236%  
ssh 3.144.11.236
sudo nano /usr/NX/etc/server.cfg
sudo /etc/NX/nxserver --restart
sudo netstat -tunlp | grep nxd

sudo lsblk
# NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# xvda     202:0    0    8G  0 disk 
# ├─xvda1  202:1    0  7.9G  0 part /
# ├─xvda14 202:14   0    4M  0 part 
# └─xvda15 202:15   0  106M  0 part /boot/efi
# xvdd     202:48   0   40G  0 disk 
sudo mkfs.ext4 /dev/xvdd
# Filesystem UUID: 0b330aec-2c60-4cf6-b432-0a08874eb80f
sudo blkid | grep /dev/xvdd
# /dev/xvdd: UUID="0b330aec-2c60-4cf6-b432-0a08874eb80f" TYPE="ext4"
sudo chown -R aabor:aabor /mnt/vol40
sudo nano /etc/fstab
# UUID=0b330aec-2c60-4cf6-b432-0a08874eb80f     /mnt/vol40       ext4   defaults,discard        0 1
sudo mount -a
# sudo mount /dev/xvdd /mnt/vol40
```
# AWS Glacier

Download .qcow2 Windows 7 virtual machine image and mount it as read only, then copy the content of 'Users' windows directory to separate volume

```sh
aws glacier get-job-output --vault-name aabor-s3-glacier --account-id - \
  --range bytes=0-34364194815 \
  --job-id fmkz6hbq5flAPS2nRVrR0f8N-Bg0r_UezqxhyAgawB9EkYAnAJ2KlAQQhw4rmpitpF5_rs6Sx7F9E0TAE9zdeKWpc19M \
  2023-01-30-win7.qcow2

sudo sudo guestmount -a /mnt/vol40/2023-01-30-win7.qcow2 -i --ro /mnt/win7
sudo ls /mnt/win7 
# '$Recycle.Bin'		  'Program Files'	  Recovery		       Users
# 'Documents and Settings'  'Program Files (x86)'   SWTOOLS		       Windows
#  PerfLogs		   ProgramData		 'System Volume Information'   pagefile.sys
cd '/mnt/win7/Users'
du -h .
# 13G	.
rsync -auxv . /mnt/vol16/

```
