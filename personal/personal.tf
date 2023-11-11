variable "password" {
  type = string
}

variable "flavor_id" {
  type    = string
  default = "c1-r1-d10"
}

variable "subnetwork_cidr" {
  type    = string
  default = "192.168.4.0/24"
}

variable "router_id" {
  type    = string
  default = "2dbfe569-9d89-491a-8968-05e36476f98a"
}

terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}


data "openstack_compute_availability_zones_v2" "zones" {
  region = "RegionOne"
}

provider "openstack" {
  user_name   = "ao223ir-2dv013"
  tenant_name = "ao223ir-2dv013-ht23"
  password    = "${var.password}"
  auth_url    = "https://cscloud.lnu.se:5000/v2.1"
  region = "RegionOne"
}

resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "${var.subnetwork_cidr}"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${var.router_id}"
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_compute_instance_v2" "instance_1" {
  name            = "instance_1"
  image_name      = "Ubuntu server 22.04.1"
  # flavor_id       = "c1-r1-d10"
  flavor_name     = "c1-r1-d10"
  # security_groups = ["default"]
  security_groups = [ "default", "${openstack_networking_secgroup_v2.ssh.id}"]
  availability_zone = "Education"
  key_pair        = "ao223ir_keypair"

  network {
    uuid = openstack_networking_network_v2.network_1.id
  }
}

resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.instance_1.id
}

# SECURITY GROUPS ------------

resource "openstack_networking_secgroup_v2" "ssh" {
  name = "ssh"
  description = "Security group for SSH"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.ssh.id}"
}

resource "local_file" "AnsibleInventory" {
  content = <<-EOF
  [webservers]
  ${openstack_compute_instance_v2.instance_1.access_ip_v4}
  ${openstack_networking_floatingip_v2.fip_1.address}
  EOF
  filename = "ansible/hosts.ini"
}

/*output "network" {
  value = openstack_compute_instance_v2.instance_1.network
}

output "floating_ip" {
 value = openstack_networking_floatingip_v2.fip_1.address
}*/