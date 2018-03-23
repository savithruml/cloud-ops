# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT ICLOUD DOT COM
# Copyright (c) 2018 Juniper Networks, Inc. All rights reserved

#!/bin/sh

# Set SSH password, keyless SSH, stat hosts & install base packages

set -eux

sudo -u root bash << EOF
sed -i -e 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart
echo root:$1 | chpasswd
apt-get update -y && apt-get install python git wget sshpass ansible -y
cd /root && git clone https://github.com/savithruml/ansible-labs
ssh-keygen -t rsa -C "" -P "" -f "/root/.ssh/id_rsa" -q
sshpass -p $1 ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@$2
sshpass -p $1 ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@$3
cd /root/ansible-labs/k8s
echo > /root/ansible-labs/k8s/hosts
cat << 'EOF' >> /root/ansible-labs/k8s/hosts
[masters]
$2
[nodes]
$3
EOF

ansible-playbook -i /root/ansible-labs/k8s/hosts /root/ansible-labs/k8s/site.yml
