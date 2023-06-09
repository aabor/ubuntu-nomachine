#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

set -x

# Install necessary dependencies
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

sudo apt update && sudo apt upgrade -y
sudo apt update && sudo apt install -y \
    apt-transport-https ca-certificates \
    ncdu `# NCurses Disk Usage a fast way to see what directories are using disk space` \
    vim `# text editor` \
    bless `# hex editor for Linux and Windows` \
    jq `# sed for JSON data` \
    curl `# command-line utility for transferring data from or to a server` \
    wget `# non-interactive network downloader` \
    xz-utils `#  XZ-format compression utilities` \
    pass `# gpg2(1) encrypted password store ~/.password-store` \
    dpkg-sig `# Debian package archive (.deb) signature generation and verification tool` \
    git `# distributed version control system` \
    gitk `# git repository browser` \
    at `# queue, examine, or delete jobs for later execution` \
    htop `# interactive process viewer` \
    dnsutils `# DNS lookup utility, contains dig, nslookup and nsupdate utilities` \
    net-tools `# NET-3 networking toolkit: arp, ifconfig, netstat, rarp, nameif and route` \
    ethtool `# query or control network driver and hardware settings` \
    inetutils-traceroute `# trace the route to a host` \
    nmap `# Network Mapper is an open source tool for network exploration and security auditing` \
    netcat `# nc open TCP connections, send UDP packets, listen on arbitrary TCP and UDP ports, do port scan‐
     ning, and deal with both IPv4 and IPv6` \
    tcpdump `# dump traffic on a network` \
    mlocate `# quickly finding files by filename` \
    cpu-checker `# to run kvm-ok command` \
    && sudo apt clean

# COMPILING SOFTWARE FROM SOURCE
sudo apt install -y \
  build-essential \
  automake \
  checkinstall

# install GCC the C compiler,
# documentation on make: http://www.gnu.org/software/make/manual/make.html
sudo apt install -y gcc make cmake && gcc --version
# g++ GNU c++ compiler invocation command, which is used for preprocessing, compilation, assembly and linking of
# source code to generate an executable file
sudo apt install -y g++ && g++ --version

sudo apt install ubuntu-gnome-desktop -y
sudo add-apt-repository universe -y
sudo apt install gnome-tweak-tool -y

sudo apt install firefox -y
# Lynx is command line browser
sudo apt install lynx -y

# nemo File Manager 
# https://www.linuxuprising.com/2018/07/how-to-replace-nautilus-with-nemo-file.html
sudo apt-get install -y nemo
#Make Nemo as the default file manager:
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.nemo.desktop show-desktop-icons true
#To list the available Nemo extensions:
# apt-cache search nemo
# start nemo:
# nemo
# bulk files rename
sudo apt install nautilus-share thunar -y
# Setup sudo to allow no-password sudo "aabor" user
sudo useradd -m -s /bin/bash aabor
sudo cp /etc/sudoers /etc/sudoers.orig
echo "aabor  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/aabor

sudo timedatectl set-timezone "America/Los_Angeles"

sudo -u aabor dbus-launch dconf write /org/gnome/shell/favorite-apps "['firefox.desktop', 'thunderbird.desktop', 'nemo.desktop', 'org.gnome.Terminal.desktop', 'rhythmbox.desktop', 'libreoffice-writer.desktop', 'deluge.desktop']"

# gsettings list-recursively
# gsettings get org.gnome.desktop.interface gtk-theme

sudo -u aabor dbus-launch gsettings set org.yorba.shotwell.preferences.ui use-dark-theme true
sudo -u aabor dbus-launch gsettings set org.gnome.rhythmbox.plugins.alternative_toolbar dark-theme true
sudo -u aabor dbus-launch gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
# never switch to black screen in power saving mode
sudo -u aabor dbus-launch gsettings set org.gnome.desktop.session idle-delay 0

sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-home-icon-toolbar true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-reload-icon-toolbar true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-previous-icon-toolbar true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-new-folder-icon-toolbar true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-list-view-icon-toolbar true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-edit-icon-toolbar true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-computer-icon-toolbar true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences show-hidden-files true
sudo -u aabor dbus-launch gsettings set org.nemo.preferences date-format 'iso'
sudo -u aabor dbus-launch gsettings set org.nemo.preferences executable-text-activation 'launch'
sudo -u aabor dbus-launch gsettings set org.nemo.preferences default-folder-viewer 'list-view'
sudo -u aabor dbus-launch gsettings set org.nemo.preferences bulk-rename-tool 'b"thunar --bulk-rename"'

# Installing SSH key
sudo mkdir -p /home/aabor/.ssh
sudo chmod 700 /home/aabor/.ssh
sudo cp /tmp/id_rsa.pub /home/aabor/.ssh/authorized_keys
sudo chmod 600 /home/aabor/.ssh/authorized_keys
sudo chown -R aabor /home/aabor/.ssh
sudo usermod --shell /bin/bash aabor

# nomachine installation
wget -O /tmp/nomachine.deb wget https://download.nomachine.com/download/8.5/Linux/nomachine_8.5.3_1_amd64.deb
sudo dpkg -i /tmp/nomachine.deb
# NX> 700 NX service on port: 4000
# sudo ufw allow 4000/udp
sudo mv /usr/NX/etc/server.cfg /usr/NX/etc/server.cfg.back
sudo cp /tmp/server.cfg /usr/NX/etc/server.cfg
# sudo /etc/NX/nxserver --debug --enable all
# setup private key based auth to nomachine
# Add the public SSH key on the server
sudo mkdir -p /home/aabor/.nx/config/
sudo chmod 700 /home/aabor/.nx/config/
sudo cp /tmp/id_rsa.pub /home/aabor/.nx/config/authorized.crt
sudo chmod 600 /home/aabor/.nx/config/authorized.crt
sudo chown -R aabor:aabor /home/aabor/.nx
# sudo /etc/NX/nxserver --restart
# sudo systemctl status nxserver
# sudo netstat -tunlp | grep nxd

sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn aabor

sudo wget -O /tmp/tor-browser.tar.xz https://www.torproject.org/dist/torbrowser/12.0.6/tor-browser-linux64-12.0.6_ALL.tar.xz
sudo tar -xf /tmp/tor-browser.tar.xz -C /home/aabor/
sudo chown -R aabor:aabor /home/aabor/tor-browser

# install Deluge torrent client
# https://www.linuxbabe.com/ubuntu/install-deluge-bittorrent-client-ubuntu-20-04
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deluge-team/stable -y
sudo apt install deluge -y
sudo mkdir -p /home/aabor/.config/deluge
sudo cp /tmp/core.conf /home/aabor/.config/deluge/

cd /tmp
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# verify aws signature
sudo curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig
sudo -u aabor gpg --import /tmp/pgp_aws.pub
sudo -u aabor gpg --verify awscliv2.sig awscliv2.zip
# gpg: Signature made Wed 23 Mar 2022 08:40:49 PM MSK
# gpg:                using RSA key FB5DB77FD5C118B80511ADA8A6310ACC4672475C
# gpg: Good signature from "AWS CLI Team <aws-cli@amazon.com>" [unknown]
# gpg: WARNING: This key is not certified with a trusted signature!
# gpg:          There is no indication that the signature belongs to the owner.
# Primary key fingerprint: FB5D B77F D5C1 18B8 0511  ADA8 A631 0ACC 4672 475C
sudo unzip awscliv2.zip
sudo ./aws/install
# You can now run: /usr/local/bin/aws --version
aws --version

# install KVM
sudo apt update
sudo apt install -y qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils
sudo systemctl enable --now libvirtd
sudo usermod -aG kvm aabor
sudo usermod -aG libvirt aabor
sudo apt-get install libguestfs-tools -y
# man guestmount

# sudo systemctl start libvirtd
# sudo systemctl status libvirtd
# ● libvirtd.service - Virtualization daemon
#      Loaded: loaded (/lib/systemd/system/libvirtd.service; enabled; vendor preset: enabled)
#      Active: active (running) since Sun 2023-06-04 18:08:34 UTC; 1min 5s ago
# TriggeredBy: ● libvirtd-admin.socket
#              ● libvirtd.socket
#              ● libvirtd-ro.socket


