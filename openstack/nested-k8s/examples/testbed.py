# EXAMPLE TESTBED WITH 1 CONTROLLER & 1 COMPUTE

# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT JUNIPER.NET
# Copyright (c) 2017 Juniper Networks, Inc. All rights reserved.

from fabric.api import env

controller = 'root@<controller-ip>'
compute = 'root@<compute-ip>'

ext_routers = []

router_asn = 64512

host_build = 'root@<controller-ip>'

env.roledefs = {
    'all': [controller,compute],
    'contrail-controller': [controller],
    'openstack': [controller],
    'contrail-compute': [compute],
    'contrail-analytics': [controller],
    'contrail-analyticsdb': [controller],
    'build': [host_build]
}

env.hostnames = {
    'all': ['<controller-hostname>,'<compute-hostname>']
}

env.passwords = {
    controller: '<ssh-password>',
    compute: '<ssh-password>',
    host_build: '<ssh-password>',
}

env.kernel_upgrade=False

env.openstack = {
    'manage_amqp': "true"
}

env.keystone = {
     'admin_password': '<contrail/horizon-web-ui-password>'
}
