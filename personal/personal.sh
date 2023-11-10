#!/bin/bash

# Navigate to your Terraform directory
##cd personal

# Initialize Terraform
terraform init

# Plan and apply Terraform changes
terraform plan -out=tfplan
terraform apply tfplan 

