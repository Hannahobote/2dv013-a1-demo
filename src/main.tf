#Some variables 

#TODO: move variables later

variable "USERNAME" {}
variable "TENANT_NAME" {}
variable "PASSWORD" {}
variable "AUTH_URL" {}
variable "REGION" {}
# others
variable "KEY_PAIR" {}
variable "subnetwork_cidr" {
  type    = string
  default = "192.168.4.0/24"
}

variable "flavor_id" {
  type    = string
  default = "c1-r1-d10"
}

variable "key_name" {
  type    = string
  default = "Please export an environment variable called TF_VAR_key_name with the name of the key that Terraform should use to build the server among the keys you have in cscloud."
}

variable "identity_file" {
  type    = string
  default = "Please export an environment variable TF_VAR_identity_file with the path to your key for ansible machine. This enables the ansible part to work."
}  



/*provider "openstack" {
  user_name   = var.USERNAME
  tenant_name = var.TENANT_NAME
  password    = var.PASSWORD
  auth_url    = var.AUTH_URL
}

resource "openstack_compute_instance_v2" "example" {
  name            = var.NAME
  image_name      = var.IMAGE_NAME
  flavor_name     = var.FLAVOR_NAME
  key_pair        = var.KEY_PAIR
  security_groups = ["default"]

  network {
    name = var.NETWORK
  }
}*/


## delete later
# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.USERNAME
  tenant_name = var.TENANT_NAME
  password    = var.PASSWORD
  auth_url    = var.AUTH_URL
  region = "RegionOne"
}

# openstack_networking_network_v2
resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "a security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_port_v2" "port_1" {
  name               = "port_1"
  network_id         = openstack_networking_network_v2.network_1.id
  admin_state_up     = "true"
  security_group_ids = [openstack_compute_secgroup_v2.secgroup_1.id]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.199.10"
  }
}

resource "openstack_compute_instance_v2" "instance_1" {
  name            = "instance_1"
  security_groups = [openstack_compute_secgroup_v2.secgroup_1.name]

  network {
    port = openstack_networking_port_v2.port_1.id
  }
}

# config code in the subnet exist in the network openstack_networking_network_v2

# compute instance
resource "openstack_compute_instance_v2" "basic" {
  name            = "basic"
  image_id        = "ad091b52-742f-469e-8f3c-fd81cadf0743"
  flavor_id       = "3"
  key_pair        = "my_key_pair_name"
  security_groups = ["default"]

  metadata = {
    this = "that"
  }

  network {
    name = "my_network"
  }
}

# compute_floatingip
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "my_pool"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.instance_1.id
}

resource "local_file" "AnsibleInventory" {
  content = <<-EOF
  [webservers]
  ${openstack_compute_instance_v2.basic.access_ip_v4}
  EOF
  filename = "${path.module}/inventory.ini"
}
