# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT ICLOUD DOT COM
# Copyright (c) 2018 Juniper Networks, Inc. All rights reserved

# Define the variables
variable "public_key_path" {}
variable "private_key_path" {}
variable "key_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "vpc_cidr" {}
variable "vpc_subnet_cidr" {}
variable "master_private_ip" {}
variable "minion_private_ip" {}
variable "aws_amis" {type="map"}
variable "instance_password" {}

# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "k8s-contrail" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "k8s-contrail" {
  vpc_id = "${aws_vpc.k8s-contrail.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "k8s-contrail" {
  route_table_id         = "${aws_vpc.k8s-contrail.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.k8s-contrail.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "k8s-contrail" {
  vpc_id                  = "${aws_vpc.k8s-contrail.id}"
  cidr_block              = "${var.vpc_subnet_cidr}"
  map_public_ip_on_launch = true
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "k8s-contrail" {
  name        = "k8s-contrail"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.k8s-contrail.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "master" {
  depends_on = ["aws_instance.minion"]
  connection {
    # The default username for our AMI
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s-contrail.id}"]
  subnet_id = "${aws_subnet.k8s-contrail.id}"
  private_ip = "${var.master_private_ip}"
  tags {
    Name = "master"
  }

  provisioner "file" {
    source      = "cloud-init/master.sh"
    destination = "/tmp/master.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/master.sh",
        "sudo /tmp/master.sh ${var.instance_password} ${var.master_private_ip} ${var.minion_private_ip}"
    ]
  }
}

resource "aws_instance" "minion" {
  connection {
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s-contrail.id}"]
  subnet_id = "${aws_subnet.k8s-contrail.id}"
  private_ip = "${var.minion_private_ip}"

  tags {
    Name = "minion"
  }

  provisioner "file" {
    source      = "cloud-init/minion.sh"
    destination = "/tmp/minion.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/minion.sh",
        "sudo /tmp/minion.sh ${var.instance_password}"
    ]
  }
}
