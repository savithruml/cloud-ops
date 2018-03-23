# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT ICLOUD DOT COM
# Copyright (c) 2018 Juniper Networks, Inc. All rights reserved

# Vars for bringing up K8s with OpenContrail SDN

# Path to the SSH public key to be used for authentication
public_key_path           = "/root/.ssh/terraform.pub"

# Path to the SSH private key to be used for authentication
private_key_path          = "/root/.ssh/terraform"

# Desired name of AWS key pair
key_name                  = "k8s-contrail"

# AWS access key
aws_access_key            = "<access-key>"

# AWS secret key
aws_secret_key            = "<secret-key>"

# AWS region
aws_region                = "us-west-1"

# AWS VPC CIDR
vpc_cidr                  = "10.10.0.0/16"

# AWS VPC subnet CIDR
vpc_subnet_cidr           = "10.10.10.0/24"

# AWS Master EC2 instance private IPv4 address
master_private_ip         = "10.10.10.10"

# AWS Minion EC2 instance private IPv4 address
minion_private_ip         = "10.10.10.11"

# AWS image ID
aws_amis                  = {"us-west-1" = "ami-07585467"}

# AWS Master/Minion EC2 instance password
instance_password         = "<instance-password>"
