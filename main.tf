terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_provider_uri 
}

locals {
    # get vms.json
    vm_data = jsondecode(file("${path.module}/topology/vms.json"))
    # vm_data = jsondecode(file("./topology/vms.json"))
    
    #example structure:
    #{
    #    "vms": 
    #    [
    #            { "hostname": "vm1", "mgmt_ip": "1.2.3.4" },
    #            { "hostname": "vm2", "mgmt_ip": "1.2.3.5" }
    #    ]
    #}

    # get all vms hostnames
    all_hostnames = [for vm in local.vm_data.vms : vm.hostname]
}

data "external" "get_vm_data" {
  program = ["python", "${path.module}/lib/topology.py"]

  query = {
    query = "get_vm_data"
    topology_file = var.topology_file
  }
}


# # create VMS using local file reader
# resource "libvirt_domain" "file_vms" {
#   for_each =  { for vm in local.vm_data.vms: vm.hostname => vm }
#   # example data:
#   # { vm1 : { "hostname": "vm1", "mgmt_ip": "1.2.3.4" }}
  
#   name = each.key
#   # name = each.value.hostname
#   # ip = each.value.mgmt_ip
# }


# # crete VMs using variables
# resource "libvirt_domain" "var_vms" {
#   for_each = toset(var.fixed_vm_list)
#   name = "${each.key}-var"
# }


resource "libvirt_volume" "ubuntu_volumes" {
  for_each = data.external.get_vm_data.result
  name   = "${each.key}.qcow2"
  pool   = "ubuntu"
  base_volume_name = "ubuntu-qcow2"
  base_volume_pool = "ubuntu"
}


data "template_file" "user_data" {
  template = file("${path.module}/templates/cloud_init.cfg")
  vars = {
    vm_root_pass = var.vm_root_pass
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/templates/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = "ubuntu"
}



# create VMs using external data provider
resource "libvirt_domain" "external_vms" {
  for_each = data.external.get_vm_data.result
  name = "${each.key}"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = lookup(libvirt_volume.ubuntu_volumes, each.key).id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
