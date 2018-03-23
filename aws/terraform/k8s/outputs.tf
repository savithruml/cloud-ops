# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT ICLOUD DOT COM
# Copyright (c) 2018 Juniper Networks, Inc. All rights reserved

output "master-public-ip" {
  value = "${aws_instance.master.public_ip}"
}

output "minion-public-ip" {
  value = "${aws_instance.minion.public_ip}"
}
