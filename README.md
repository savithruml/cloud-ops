# Red Hat OpenShift Origin with Contrail SDN

This tutorial walks you through the installation of Red Hat OpenShift container orchestration platform with Contrail SDN as the CNI on Amazon Web Services (AWS). 

It leverages AWS's CloudFormation to launch the stack & takes approximately 30 min for the total installation to complete. The stack builds

* Red Hat OpenShift Origin v3.7
* Contrail Networking CNI 5.0

# Prerequisites

* [Create](https://portal.aws.amazon.com/billing/signup#/start) an AWS account if you don't have one. Else [Login](https://aws.amazon.com/console/)

* [Subscribe](https://aws.amazon.com/marketplace/pp/B00O7WM7QW) to CentOS AMI on AWS marketplace

* [Create](https://github.com/join) a GitHub account if you don't have one. Else [Login](https://github.com/login)

# Installation

* Click on the button below to launch the stack in AWS

     <a href="https://us-west-1.console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/create/review?filter=active&templateURL=https:%2F%2Fs3-us-west-1.amazonaws.com%2Fcontrail-dev-ops%2Fopenshift-contrail-stack-5.yaml&stackName=openshift-stack" target="_blank"><img alt="Launch Stack" src="https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg"></a>

* Once you click on the button, you will be navigated to AWS CloudFormation page. Enter the parameters

  ![launch-stack](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/1-initiate.jpg)

    **NOTE:** You can leave most of the parameters set to default

       InstanceType:
         Description: EC2 instance type
         Default: t2.xlarge

       VpcCIDR:
         Description: CIDR block for the VPC
         Default: 10.10.0.0/16

       SubnetCIDR:
         Description: CIDR block for the VPC subnet
         Default: 10.10.10.0/24
    
       MasterIPv4Address:
         Description: Master instance's IPv4 Address
         Default: 10.10.10.10

       MinionIPv4Address:
         Description: Minion instance's IPv4 Address
         Default: 10.10.10.11
   
       SSHLocation:
         Description: Allow access to EC2 instances from
         Default: 0.0.0.0/0

       InstancePassword:
         Description: Password for the instances

       ContrailBuild:
         Description: Contrail build information
         Default: 5.0

       ContrailRegistry:
         Description: Registry to pull Contrail containers
         Default: hub.juniper.net/contrail
    
       ContrailRegistryUsername:
         Description: Registry username
    
       ContrailRegistryPassword:
         Description: Registry password

* Wait for the stack to complete. You can monitor the resource creation by clicking on the **Events** tab
  
  ![monitor-stack](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/2-monitor.jpg)

* Once complete, navigate to the **Outputs** tab & copy the ShellURL value. Login to the instance using the ShellURL & the password you set

  ![complete-stack](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/3-complete.jpg)

* Run the script from the master instance's /root directory

       (local-instance)# ssh root@ec2-<public-ip>.us-west-1.compute.amazonaws.com

       (master-instance)# cd /root
       (master-instance)# ~/run.sh

  ![run-stack](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/4-run-sh.jpg)

* Once install is complete, login to the dashboards (WebUI) of both OpenShift & Contrail. The URL's are listed in the **Outputs** tab of AWS CloudFormation

  ![openshift-webui](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/6-openshift-webui.png)

  ![contrail-webui](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/7-contrail-webui.png)

* Verify all Contrail pods are running healthy, by logging into OpenShift & Contrail dashboards

    **_OpenShift Dashboard > My Projects > kube-system > Applications > Pods_**

  ![contrail-pods](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/8-contrail-pods.png)

    **_Contrail Dashboard > Monitor > Infrastructure > Dashboard_**

  ![contrail-status](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/9-contrail-status.png)

* Enable SNAT on the pod network, by logging into Contrail dashboard

    **_Contrail Dashboard > Configure > Networking > Networks > default-domain > default> k8s-default-pod-network (edit)_**

  ![enable-snat](https://github.com/savithruml/cloud-ops/blob/master/aws/cloudformation/openshift/images/10-enable-snat.jpg)

* Try the below labs

    1. [LAB-1: Build/test/deploy highly scalable apps using OpenShift & Contrail SDN](https://s3-us-west-1.amazonaws.com/contrail-labs/usecase-1-openshift-build.pdf)
    2. [LAB-2: Expose highly scalable apps using OpenShift & Contrail SDN](https://s3-us-west-1.amazonaws.com/contrail-labs/usecase-2-openshift-ingress.pdf)
    3. [LAB-3: Secure highly scalable apps using OpenShift & Contrail SDN](https://s3-us-west-1.amazonaws.com/contrail-labs/usecase-3-openshift-network-policy.pdf)
