# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT ICLOUD DOT COM
# Copyright (c) 2018 Juniper Networks, Inc. All rights reserved

output "Contrail Master DNS" {
  value = "${data.azurerm_public_ip.contrail-master-public-ip.domain_name_label}"
}

output "Contrail Master Public IPv4 Address" {
  value = "${data.azurerm_public_ip.contrail-master-public-ip.ip_address}"
}

output "Contrail Minion DNS" {
  value = "${data.azurerm_public_ip.contrail-minion-public-ip.domain_name_label}"
}

output "Contrail Minion Public IPv4 Address" {
  value = "${data.azurerm_public_ip.contrail-minion-public-ip.ip_address}"
}