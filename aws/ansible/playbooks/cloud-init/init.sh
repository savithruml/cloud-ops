#!/bin/bash

# Enable root login
sudo -u root bash << EOF
sed -i -e 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart

# Set root password
echo "root:c0ntrail123" | chpasswd

# Install dependencies
apt-get update -y && apt-get install python -y
