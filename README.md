# PXE Provisioning Server

## Purpose

Setup Ubuntu 14.04 server as a PXE server for OS installations.  The steps
carried out by the provision.sh script include:

1. Install required packages
2. Install and configure Nginx to server boot files
3. Configure ufw for NAT
4. Configure dnsmasq (DHCP server, DNS server, TFTP server)
5. Prepare PXE boot files
6. Extract installers 

## How to use

- Add Ubuntu 14.04 Server ISO (configured for: ubuntu-14.04.1-server-amd64.iso)
- Add ESXi 5.5 ISO (configured for: Vmware-ESXi-5.5.0-2068190-custom-Cisco-5.5.2.2.iso)
- Edit the provision.sh to work with your ISO names and extraction folders
- Edit pxelinux.cfg/default for your installers
- Edit the provision.sh script with your server's IP address
- Edit dnsmasq.conf with interface and DHCP range
- Run the provision.sh script
- Start dnsmasq

[ ] TODO: Start dnsmasq automatically (on boot)

# License

This content is licensed under the MIT License.