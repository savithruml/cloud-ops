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
apt-get update -y && apt-get install python -y
