# AWS

## AWS CloudFormation

* Kubernetes with OpenContrail SDN

     <a href="https://console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/new?stackName=contrail-k8s&amp;templateURL=https://s3-us-west-1.amazonaws.com/contrail-dev-ops/k8s-contrail-stack.yaml" target="_blank"><img alt="Launch Stack" src="https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg"></a>

## HashiCorp Terraform

* Kubernetes with OpenContrail SDN

      (host)# terraform apply
      
## Ansible playbook

* Kubernetes with OpenContrail SDN

    1) Bring your ansible node. This node can either sit indide the AWS environment or outside
    
            (ansible-node)# apt-get update -y && apt-get install python python-pip -y
            (ansible-node)# pip install -U ansible boto boto3
      
            (ansible-node)# cd /root
            (ansible-node)# git clone https://github.com/savithruml/ansible-labs
            
    2) Populate /root/ansible-labs/aws/playbooks/group_vars/all file with AWS creds & cluster info
      
            (ansible-node)# cat /root/ansible-labs/aws/playbooks/group_vars/all
            
                  aws_access_key: <key-here> 
                  aws_secret_key: <secret-key-here>
                  key_name: <key>
                  aws_region: <region>
                  vpc_id: <vpc>
                  vpc_subnet_id: <subnet>
                  ami_id: <image>
                  instance_type: <flavor>
                  count: 2
                  ec2_tag: contrail-k8s
                 
            (ansible-node)# cd /root/ansible-labs/aws       
            (ansible-node)# ansible-playbook -i inventory/hosts playbooks/deploy-vms.yml
            
        This should bring up 2 instances in AWS with root password set to "c0ntrail123"
    
    4) Prepare nodes for deployment

    5) Run these commands on all nodes. This will enable root access with password
    
            (all-nodes)# sudo su
            (all-nodes)# sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/g' -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config 
            (all-nodes)# service sshd restart
    
    6) Logout & login as root user
    
            (ansible-node)# ssh-keygen –t rsa
            (ansible-node)# ssh-copy-id root@<k8s-master>
            (ansible-node)# ssh-copy-id root@<k8s-node>
             
    7) Populate /root/ansible-labs/k8s/hosts with k8s-master & k8s-node info
    
            (ansible-node)# cat /root/ansible-labs/k8s/hosts
       
               [masters]
               10.10.10.1

               [nodes]
               10.10.10.2
        
    8) Run the play
 
            (ansible-node)# cd /root/ansible-labs/k8s
            (ansible-node)# ansible-playbook -i hosts site.yml
