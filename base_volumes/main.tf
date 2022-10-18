terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

variable "libvirt_provider_uri" {
  type = string
  default = "qemu:///system"
}

provider "libvirt" {
  uri = var.libvirt_provider_uri 
}


resource "libvirt_pool" "ubuntu" {
  name = "ubuntu"
  type = "dir"
  path = "/var/lib/libvirt/images/pool-ubuntu"
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu-qcow2" {
  name   = "ubuntu-qcow2"
  pool   = libvirt_pool.ubuntu.name
  source = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
  format = "qcow2"
}
