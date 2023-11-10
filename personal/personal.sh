#!/bin/bash

# Navigate to your Terraform directory
##cd personal

# Initialize Terraform
terraform init

# Plan and apply Terraform changes
terraform plan -out=tfplan
terraform apply tfplan 

# Navigate to your Ansible directory
cd ansible

# Run your Ansible playbook
# ansible-playbook playbook.yml
ansible-playbook -i hosts.ini playbook.yml

