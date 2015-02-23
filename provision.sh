#!/bin/sh
SRC=/vagrant/pxe-installer/files
BOOTFILES=/provisioning
INSTALL_HOST=10.199.199.10

## Install required packages
sudo apt-get update -q
sudo apt-get install -qy nginx dnsmasq ipxe p7zip-full

## Create provisioning folder
mkdir $BOOTFILES
cd $BOOTFILES

## Configure Nginx
cp $SRC/nginx-default /etc/nginx/sites-available/provisioning
ln -s /etc/nginx/sites-available/provisioning /etc/nginx/sites-enabled/provisioning
rm /etc/nginx/sites-enabled/default
service nginx reload

## Configure dnsmasq
sed -e "s/<HTTP_HOST>/$INSTALL_HOST/g" $SRC/dnsmasq.conf > /etc/dnsmasq.conf 
service dnsmasq restart

## Configure NAT (ONLY NEEDED ON ISOLATED NETWORKS)
mv /etc/ufw/before.rules /etc/ufw/before.rules.original
cp $SRC/before.rules /etc/ufw/
sed -e "s/DEFAULT_INPUT_POLICY=\"DROP\"/DEFAULT_INPUT_POLICY=\"ACCEPT\"/g" -i /etc/default/ufw
sed -e "s/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/g" -i /etc/default/ufw
sed -e "s/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/g" -i /etc/ufw/sysctl.conf
ufw disable && sudo ufw --force enable

## Copy in the iPXE boot files (symlink is because dnsmasq in proxy mode needs the .0)
cp /usr/lib/ipxe/undionly.kpxe $BOOTFILES
ln -s $BOOTFILES/undionly.kpxe $BOOTFILES/undionly.kpxe.0

## Drop in our iPXE boot files
cp $SRC/boot.ipxe $BOOTFILES/boot.ipxe
sed -e "s/<HTTP_HOST>/$INSTALL_HOST/g" $SRC/boot.ipxe.cfg > $BOOTFILES/boot.ipxe.cfg

# Copy ISO files
mkdir $BOOTFILES/iso
rsync --progress $SRC/iso/* $BOOTFILES/iso/

## Extract ISO for ESXi 5.5u2 (Cisco)
#7z x -o"$BOOTFILES/esxi_5.5u2_cisco" $SRC/Vmware-ESXi-5.5.0-2068190-custom-Cisco-5.5.2.2.iso
## Files must be lower case
#rename 'y/A-Z/a-z/' $BOOTFILES/esxi_5.5u2_cisco/*.*
## Edit the boot.cfg to use HTTP
#sed -e "s/\//http:\/\/$INSTALL_HOST\/esxi_5.5u2_cisco\//g" -i $BOOTFILES/esxi_5.5u2_cisco/boot.cfg

## Extract ISO for Ubuntu 14.04 Server
#7z x -o"$BOOTFILES/ubuntu-14.04-srv" $SRC/ubuntu-14.04.1-server-amd64.iso

# Set permissions on our boot folder
chmod go+rx $(find $BOOTFILES -type d)
