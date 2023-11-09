#!/bin/bash

# Ask the user for input
echo "Please enter your variable values:"

read -p "Openstack username: " username
read -p "Openstack tenant_name: " tenant_name
read -p "Openstack password: " password
read -p "Openstack auth_url: " auth_url
#read -p "Openstack region: " region
#read -p "Openstack name: " name
#read -p "Openstack image_name: " image_name
#read -p "Openstack flavor_name: " flavor_name
read -p "Openstack file path to your key_pair: " key_pair
read -p "Openstack file path to your key_name: " key_name
#read -p "Openstack network: " network


# Navigate to your Terraform directory
cd src/

# Set Terraform variables
export TF_VAR_USERNAME="$username"
export TF_VAR_TENANT_NAME="$tenant_name"
export TF_VAR_PASSWORD="$password"
export TF_VAR_AUTH_URL="$auth_url"
#export TF_VAR_REGION="$region"
#export TF_VAR_NAME="$name"
#export TF_VAR_IMAGE_NAME="$image_name"
#export TF_VAR_FLAVOR_NAME="$flavor_name"
export TF_VAR_KEY_PAIR="$key_pair"
export TF_VAR_KEY_NAME="$key_name"
#export TF_VAR_NETWORK="$network"


# Initialize Terraform
terraform init

# Plan and apply Terraform changes
terraform plan
terraform apply -auto-approve
