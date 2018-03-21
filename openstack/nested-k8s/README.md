# Nested Mode (Contrail Networking)

## Overview

* Run Kubernetes/OpenShift container orchestration platforms on OpenStack
* One SDN controller to manage Container/VM/BareMetal workloads
* Simplified install through Heat orchestration engine

## Architecture

![Architecture](screenshots/nested-k8s-contrail.png)

## Getting started

### Prerequisites

* [Contrail-Cloud 4.X](https://www.juniper.net/support/downloads/?p=contrail#sw)

* [Contrail-Server-Manager](https://www.juniper.net/support/downloads/?p=contrail#sw)

* [CentOS-7.3-minimal with kernel-devel/headers](http://10.84.5.120/cs-shared//images/centos-nested-image.img)

* TWO x86 servers

      CPUs:     32 (2 threads/core)
      RAM:      > 64 GB
      DISK:     > 500 GB

* Gateway for Internet connectivity

* Routable IP address block for GUI/Ingress

### Install

#### CONTRAIL CLOUD

* Install Contrail-Cloud (Liberty/Mitaka/Newton) using Contrail-Server-Manager

      (openstack-controller)# > /etc/apt/sources.list
      (openstack-controller)# dpkg –i <contrail-server-manager-installer_4.0.0.0-<build-number><sku>_all.deb>
      
* Populate the testbed/JSON

     Refer to [example-testbed](https://github.com/savithruml/nested-mode-contrail-networking/tree/master/examples/testbed.py) if using Contrail 4.0.X & provision the cluster

      (openstack-controller)# /opt/contrail/contrail_server_manager/provision_containers.sh -t <testbed.py path> -c <contrail-cloud-docker.tgz> --cluster-id <user-defined-cluster-name> -d <domain-name> --no-sm-webui
      
     Refer to [example-jsons](https://github.com/savithruml/nested-mode-contrail-networking/tree/master/examples/jsons) if using Contrail 4.1.X & provision the cluster
     
      (openstack-controller)# /opt/contrail/contrail_server_manager/provision_containers.sh -cj <cluster.json path> -sj <server.json path> -ij <image.json path>
      
* Monitor status

      (openstack-controller)# /opt/contrail/contrail_server_manager/provision_status.sh
      
* After provision completes, check if all services are up & running

      (all-nodes)# contrail-status
      
* From the Contrail Web-UI, create a BGP router object & associate it with the controller

    ![BGP-Router](screenshots/bgp-router.png)
      
* Create a public virtual-network & assign the routable IP address block

    ![Public-VN](screenshots/public-vn.png)
      
* Launch a virtual-machine in the public VN & verify it can talk to the outside world

      (virtual-machine)# ping 8.8.8.8
      (virtual-machine)# ping google.com

#### NESTED KUBERNETES      

* Download the CentOS image & upload it to glance

      (openstack-controller)# wget http://10.84.5.120/cs-shared//images/centos-nested-image.img
      (openstack-controller)# glance image-create --name centos-nested-image --visibility=public --container-format ovf --disk-format qcow2 --file centos-nested-image.img
      
* Clone this [repo](https://github.com/savithruml/nested-mode-contrail-networking)

      (openstack-controller)# git clone https://github.com/savithruml/nested-mode-contrail-networking

* Populate the environment file

      (openstack-controller)# vi /root/nested-mode-contrail-networking/provisioning/heat/deploy-nested.env
      
  Refer to [example-file](https://github.com/savithruml/nested-mode-contrail-networking/blob/master/examples/example-nested-k8s.env)
  
* Create the heat stack

      (openstack-controller)# cd nested-mode-contrail-networking/provisioning/heat/
      (openstack-controller)# heat stack-create nested -f deploy-nested.yaml -e deploy-nested.env
      
* Monitor the status

      (openstack-controller)# heat stack-list
      (openstack-controller)# heat stack-show nested

* Get the master/slave IP

      (openstack-controller)# heat stack-show nested | grep "output_"
  
  Login to nova-instances & tail on init logs for status
  
      (overcloud-nested-nodes)# tail -f /var/log/cloud-init-output.log -f /var/log/cloud-init.log -f /var/log/messages

* Once installation is complete, create Kubernetes dashboard

      (overcloud-nested-master)# kubectl create -f /root/k8s-dashboard.yml
      
  Wait till the **_k8s-dashboard_** pod comes up
  
      (overcloud-nested-master)# kubectl get pods -o wide --all-namespaces | grep -i "dashboard"
      
* Open browser & navigate to **_http://nested-slave-ip:9090_**

     ![browser](screenshots/k8s-dashboard.png)
      
* Launch a pod (container) in the public virtual-network

      (overcloud-nested-master)# kubectl create -f /root/custom-app.yml
      
  Wait till the **_custom-app_** pod comes up
  
      (overcloud-nested-master)# kubectl get pods -o wide
      (overcloud-nested-master)# kubectl describe pod custom-app

     ![k8s-pod-dashboard](screenshots/k8s-pod-dashboard.png)
      
* Once the pod is up, launch a virtual-machine (OpenStack Horizon) in the public virtual-network

     ![openstack-vm-dashboard](screenshots/openstack-vm-dashboard.png)

  **NOTE**: Edit **_default_** security-group to allow ICMP traffic 

     ![openstack-security-groups](screenshots/edit-security-groups.png)

* Once the virtual-machine is up, ping the virtual-machine from the pod

      (overcloud-nested-master)# kubectl exec -it custom-app ping <VM-In-Public-Network>
      
  The ping will go through, since the virtual-machine & the pod are a part of the same virtual-network

     ![ping-vm-from-pod](screenshots/ping-vm-from-pod.png)

* Now create a new virtual-network, give it a user-defined name (_Eg. red-network_) & a subnet

     ![red-network](screenshots/red-network.png)
     
  Launch a virtual-machine from the OpenStack Horizon dashboard in the newly created virtual-network
  
     ![red-network-vm](screenshots/red-network-vm.png)
     
  Launch a pod in the newly created virtual-network
  
      (overcloud-nested-master)# cp /root/custom-app.yml /root/custom-app-red.yml
      (overcloud-nested-master)# sed -i -e 's/public/red-network/g' -e 's/custom-app/custom-app-red/g' /root/custom-app-red.yml
      (overcloud-nested-master)# kubectl create -f /root/custom-app-red.yml
      
  Wait till the **_custom-app-red_** pod comes up
  
      (overcloud-nested-master)# kubectl get pods -o wide
      (overcloud-nested-master)# kubectl describe pod custom-app-red
  
     ![red-network-pod](screenshots/red-network-pod.png)
     
* Create a network policy to allow traffic between **_public_** & the newly created **_red-network_**

     ![red-to-public](screenshots/red-to-public.png)
     
* Verify that the ping goes through between the **_public_** & **_red-network_** workloads (Pods/VMs/Baremetals)

      (overcloud-nested-master)# kubectl exec -it custom-app ping <Pod-In-Red-Network>
      (overcloud-nested-master)# kubectl exec -it custom-app ping <VM-In-Red-Network>
      (overcloud-nested-master)# kubectl exec -it custom-app ping <VM-In-Public-Network>

     ![ping-all](screenshots/ping-all.png)

#### NESTED OPENSHIFT

            <Work in progress>

### Uninstall

* Delete contrail-objects
            
            <Work in progress> 
            DO IT MANUALLY FOR NOW
    
* Delete stack
    
      (openstack-controller)# heat stack-delete nested -y


## Issues/Bugs/Feature-Requests

* [Raise it here](https://github.com/savithruml/nested-mode-contrail-networking/issues)
