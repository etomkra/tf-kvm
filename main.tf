terraform {
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

# create VMS using local file reader
resource "libvirt_domain" "file_vms" {
  for_each =  { for vm in local.vm_data.vms: vm.hostname => vm }
  # example data:
  # { vm1 : { "hostname": "vm1", "mgmt_ip": "1.2.3.4" }}
  
  name = each.key
  # name = each.value.hostname
  # ip = each.value.mgmt_ip
}

resource "libvirt_domain" "external_vms" {
  for_each = data.external.get_vm_data.result
  name = "${each.key}-ex"
}


data "external" "get_vm_data" {
  program = ["python", "${path.module}/lib/topology.py"]

  query = {
    query = "get_vm_data"
    topology_file = var.topology_file
  }
}

