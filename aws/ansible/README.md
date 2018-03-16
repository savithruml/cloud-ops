### LAUNCH INSTANCES (Automated)

    * Bring your ansible node. This node can either sit indide the AWS environment or outside
    
            (ansible-node)# apt-get update -y && apt-get install python python-pip -y
            (ansible-node)# pip install -U ansible boto boto3
      
            (ansible-node)# cd /root
            (ansible-node)# git clone https://github.com/savithruml/ansible-labs
            
    * Populate /root/ansible-labs/aws/playbooks/group_vars/all file with AWS creds & cluster info
      
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
            
    * This should bring up 2 instances in AWS with root password set to "c0ntrail123"
