#!/bin/sh
SRC=/vagrant/pxe-srv
BOOTFILES=/provisioning
HTTP_HOST=10.199.199.10

## Install required packages
sudo apt-get update -q
sudo apt-get install -qy nginx syslinux dnsmasq-base p7zip-full

## Install nginx config
cp $SRC/nginx-default /etc/nginx/sites-available/provisioning
ln -s /etc/nginx/sites-available/provisioning /etc/nginx/sites-enabled/provisioning
rm /etc/nginx/sites-enabled/default
service nginx reload

## Configure dnsmasq
cp $SRC/dnsmasq.conf /etc

## Create provisioning folder
mkdir $BOOTFILES
cd $BOOTFILES

## Populate PXE boot files from the packaged syslinux
cp /usr/lib/syslinux/gpxelinux.0 $BOOTFILES
cp /usr/lib/syslinux/menu.c32 $BOOTFILES

## Drop in our PXE configuration file
mkdir $BOOTFILES/pxelinux.cfg
sed -e "s/<HTTP_HOST>/$HTTP_HOST/g" $SRC/pxelinux.cfg/default > $BOOTFILES/pxelinux.cfg/default

## Extract ISO for ESXi 5.5u2 (Cisco)
7z x -o"$BOOTFILES/esxi_5.5u2_cisco" $SRC/Vmware-ESXi-5.5.0-2068190-custom-Cisco-5.5.2.2.iso
## Files must be lower case
rename 'y/A-Z/a-z/' $BOOTFILES/esxi_5.5u2_cisco/*.*
## Edit the boot.cfg to use HTTP
sed -e "s/\//http:\/\/$HTTP_HOST\/esxi_5.5u2_cisco\//g" -i $BOOTFILES/esxi_5.5u2_cisco/boot.cfg

## Extract ISO for Ubuntu 14.04 Server
7z x -o"$BOOTFILES/ubuntu-14.04-srv" $SRC/ubuntu-14.04.1-server-amd64.iso
## Fix issue with this media...
mv $BOOTFILES/ubuntu-14.04-srv/pool/main/l/linux/firewire-core-modules-3.13.0-32-generic-di_3.13.0-32.57_amd64.ude $BOOTFILES/ubuntu-14.04-srv/pool/main/l/linux/firewire-core-modules-3.13.0-32-generic-di_3.13.0-32.57_amd64.udeb
mv $BOOTFILES/ubuntu-14.04-srv/pool/main/l/linux/pcmcia-storage-modules-3.13.0-32-generic-di_3.13.0-32.57_amd6.ude $BOOTFILES/ubuntu-14.04-srv/pool/main/l/linux/pcmcia-storage-modules-3.13.0-32-generic-di_3.13.0-32.57_amd6.udeb

# Set permissions on our boot folder
chmod go+rx $(find $BOOTFILES -type d)