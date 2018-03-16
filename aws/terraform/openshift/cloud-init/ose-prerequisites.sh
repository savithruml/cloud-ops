#!/bin/sh

# Set SSH password, keyless SSH, stat hosts & install base packages

set -eux

sudo subscription-manager register --username <username> --password <password> --force
sudo subscription-manager attach --pool=<pool>
sudo yum update -y
sudo subscription-manager repos --disable="*"
sudo subscription-manager repos \
                --enable="rhel-7-server-rpms" \
                --enable="rhel-7-server-extras-rpms" \
                --enable="rhel-7-server-ose-3.7-rpms" \
                --enable="rhel-7-fast-datapath-rpms"
sudo yum install wget -y
sudo wget -O /tmp/epel-release-latest-7.noarch.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
sudo rpm -ivh /tmp/epel-release-latest-7.noarch.rpm
sudo yum update -y
sudo yum install python-netaddr atomic-openshift-excluder atomic-openshift-utils git -y
sudo atomic-openshift-excluder unexclude -y
sudo yum install vim -y
sudo sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/g' -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo service sshd restart
