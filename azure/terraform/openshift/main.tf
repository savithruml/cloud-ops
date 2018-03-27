# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT ICLOUD DOT COM
# Copyright (c) 2018 Juniper Networks, Inc. All rights reserved

variable "azure_region" {
    default = "eastus"
}

variable "azure_resource_group_name" {
    default = "ContrailResourceGroup"
}

variable "azure_tags" {
    default = "Contrail Demo"
}

variable "azure_virtual_network_cidr" {
    default = "10.0.0.0/16"
}

variable "azure_virtual_network_cidr_subnet_contrail" {
    default = "10.0.1.0/24"
}

variable "azure_virtual_network_cidr_subnet_azure" {
    default = "10.0.2.0/24"
}

variable "azure_instance_flavor_type" {
    default = "Standard_DS12_v2"
}

variable "azure_os_image" {
    default     = "centos"
}

variable "azure_os_image_map" {
    type        = "map"

    default = {
        centos_publisher = "Openlogic"
        centos_offer     = "CentOS"
        centos_sku       = "7.3"
        centos_version   = "latest"
        rhel_publisher   = "RedHat"
        rhel_offer       = "RHEL"
        rhel_sku         = "7.3"
        rhel_version     = "latest"
    }
}

variable "azure_instance_username" {
    default = "default"
}

variable "azure_instance_password" {
    default = "default"
}

variable azure_rhel_subscription_username {
    default = "default"
}

variable azure_rhel_subscription_password {
    default = "default"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "ContrailResourceGroup" {
    name     = "${var.azure_resource_group_name}"
    location = "${var.azure_region}"

    tags {
        environment = "${var.azure_tags}"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        resource_group = "${azurerm_resource_group.ContrailResourceGroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "contrail-storage-account" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.ContrailResourceGroup.name}"
    location                    = "${var.azure_region}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "contrail-network" {
    name                = "contrail-network"
    address_space       = ["${var.azure_virtual_network_cidr}"]
    location            = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.ContrailResourceGroup.name}"

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create subnet
resource "azurerm_subnet" "contrail-fabric-subnet" {
    name                 = "contrail-fabric-subnet"
    resource_group_name  = "${azurerm_resource_group.ContrailResourceGroup.name}"
    virtual_network_name = "${azurerm_virtual_network.contrail-network.name}"
    address_prefix       = "${var.azure_virtual_network_cidr_subnet_contrail}"
}

resource "azurerm_subnet" "azure-fabric-subnet" {
    name                 = "azure-fabric-subnet"
    resource_group_name  = "${azurerm_resource_group.ContrailResourceGroup.name}"
    virtual_network_name = "${azurerm_virtual_network.contrail-network.name}"
    address_prefix       = "${var.azure_virtual_network_cidr_subnet_azure}"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "contrail-sec-grp" {
    name                = "contrail-sec-grp"
    location            = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.ContrailResourceGroup.name}"

    security_rule {
        name                       = "AllowAll"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create Master public IP
resource "azurerm_public_ip" "contrail-master-public-ip" {
    name                         = "masterPublicIP"
    location                     = "${var.azure_region}"
    resource_group_name          = "${azurerm_resource_group.ContrailResourceGroup.name}"
    public_ip_address_allocation = "dynamic"
    domain_name_label            = "contrail-os-master"

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create Minion public IP
resource "azurerm_public_ip" "contrail-minion-public-ip" {
    name                         = "minionPublicIP"
    location                     = "${var.azure_region}"
    resource_group_name          = "${azurerm_resource_group.ContrailResourceGroup.name}"
    public_ip_address_allocation = "dynamic"
    domain_name_label            = "contrail-os-minion"

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create Master network interface
resource "azurerm_network_interface" "contrail-master-nic" {
    name                      = "contrailMasterNIC"
    location                  = "${var.azure_region}"
    resource_group_name       = "${azurerm_resource_group.ContrailResourceGroup.name}"
    network_security_group_id = "${azurerm_network_security_group.contrail-sec-grp.id}"

    ip_configuration {
        name                          = "masterNIC"
        subnet_id                     = "${azurerm_subnet.contrail-fabric-subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.contrail-master-public-ip.id}"
    }

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create Minion network interface
resource "azurerm_network_interface" "contrail-minion-nic" {
    name                      = "contrailMinionNIC"
    location                  = "${var.azure_region}"
    resource_group_name       = "${azurerm_resource_group.ContrailResourceGroup.name}"
    network_security_group_id = "${azurerm_network_security_group.contrail-sec-grp.id}"

    ip_configuration {
        name                          = "masterNIC"
        subnet_id                     = "${azurerm_subnet.contrail-fabric-subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.contrail-minion-public-ip.id}"
    }

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create Master virtual machine
resource "azurerm_virtual_machine" "contrail-os-master" {
    name                  = "contrail-os-master"
    location              = "${var.azure_region}"
    resource_group_name   = "${azurerm_resource_group.ContrailResourceGroup.name}"
    network_interface_ids = ["${azurerm_network_interface.contrail-master-nic.id}"]
    vm_size               = "${var.azure_instance_flavor_type}"

    storage_os_disk {
        name              = "contrailMasterOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Openlogic"
        offer     = "CentOS"
        sku       = "7.3"
        version   = "latest"
        publisher = "${lookup(var.azure_os_image_map, join("_publisher", list(var.azure_os_image, "")))}"
        offer     = "${lookup(var.azure_os_image_map, join("_offer", list(var.azure_os_image, "")))}"
        sku       = "${lookup(var.azure_os_image_map, join("_sku", list(var.azure_os_image, "")))}"
        version   = "${lookup(var.azure_os_image_map, join("_version", list(var.azure_os_image, "")))}"
    }

    os_profile {
        computer_name  = "contrail-os-master"
        admin_username = "${var.azure_instance_username}"
        admin_password = "${var.azure_instance_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.contrail-storage-account.primary_blob_endpoint}"
    }

    connection {
        user = "${var.azure_instance_username}"
        password = "${var.azure_instance_password}"
        host = "${azurerm_public_ip.contrail-master-public-ip.fqdn}"
        type = "ssh"
        agent = "false"
    }

    provisioner "file" {
        source      = "cloud-init/master.sh"
        destination = "/tmp/master.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/master.sh",
            "echo ${var.azure_instance_password} | sudo -S /tmp/master.sh ${var.azure_instance_password} ${var.azure_rhel_subscription_username} ${var.azure_rhel_subscription_password}"
        ]
    }

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create Master virtual machine
resource "azurerm_virtual_machine" "contrail-os-minion" {
    name                  = "contrail-os-minion"
    location              = "${var.azure_region}"
    resource_group_name   = "${azurerm_resource_group.ContrailResourceGroup.name}"
    network_interface_ids = ["${azurerm_network_interface.contrail-minion-nic.id}"]
    vm_size               = "${var.azure_instance_flavor_type}"

    storage_os_disk {
        name              = "contrailMinionOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Openlogic"
        offer     = "CentOS"
        sku       = "7.3"
        version   = "latest"
        publisher = "${lookup(var.azure_os_image_map, join("_publisher", list(var.azure_os_image, "")))}"
        offer     = "${lookup(var.azure_os_image_map, join("_offer", list(var.azure_os_image, "")))}"
        sku       = "${lookup(var.azure_os_image_map, join("_sku", list(var.azure_os_image, "")))}"
        version   = "${lookup(var.azure_os_image_map, join("_version", list(var.azure_os_image, "")))}"
    }

    os_profile {
        computer_name  = "contrail-os-minion"
        admin_username = "${var.azure_instance_username}"
        admin_password = "${var.azure_instance_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.contrail-storage-account.primary_blob_endpoint}"
    }

    connection {
        user = "${var.azure_instance_username}"
        password = "${var.azure_instance_password}"
        host = "${azurerm_public_ip.contrail-minion-public-ip.fqdn}" 
        type = "ssh"
        agent = "false"
    }

    provisioner "remote-exec" {
        inline = [
            "wget https://raw.githubusercontent.com/savithruml/cloud-ops/master/azure/terraform/openshift/cloud-init/minion.sh",
            "chmod +x minion.sh",
            "echo ${var.azure_instance_password} | sudo -S sh ./minion.sh",
        ]
    }

    tags {
        environment = "${var.azure_tags}"
    }
}

# Create a Data source for Master
data "azurerm_public_ip" "contrail-master-public-ip" { 
    name                         = "${azurerm_public_ip.contrail-master-public-ip.name}"
    resource_group_name          = "${azurerm_resource_group.ContrailResourceGroup.name}" 
    depends_on                   = ["azurerm_virtual_machine.contrail-os-master"]
}

# Create a Data source for Minion
data "azurerm_public_ip" "contrail-minion-public-ip" { 
    name                         = "${azurerm_public_ip.contrail-minion-public-ip.name}"
    resource_group_name          = "${azurerm_resource_group.ContrailResourceGroup.name}" 
    depends_on                   = ["azurerm_virtual_machine.contrail-os-minion"]
}
