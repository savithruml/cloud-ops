# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT ICLOUD DOT COM
# Copyright (c) 2018 Juniper Networks, Inc. All rights reserved

# Azure region
azure_region                                      = "eastus"

# Azure resource group name
azure_resource_group_name                         = "ContrailResourceGroup"

# Azure tags for resources
azure_tags                                        = "contrail demo"

# Azure Virtual Network address range
azure_virtual_network_cidr                        = "10.0.0.0/16"

# Azure Virtual Network subnet address range for Contrail fabric
azure_virtual_network_subnet_contrail_cidr        = "10.0.1.0/24"

# Azure Virtual Network subnet address range for Azure fabric
azure_virtual_network_subnet_azure_cidr           = "10.0.2.0/24"

# Azure Virtual Machine instance flavor type
azure_instance_flavor_type                        = "Standard_DS12_v2"

# Azure Virtual Machine OS image
azure_os_image                                    = "centos"

# Azure Virtual Machine desired username
azure_instance_username                           = "contrail"

# Azure Virtual Machine desired password
azure_instance_password                           = "hello-world"

# Azure RHEL subscription username
azure_rhel_subscription_username                  = "hello-world"

# Azure RHEL subscription password
azure_rhel_subscription_password                  = "hello-world"
