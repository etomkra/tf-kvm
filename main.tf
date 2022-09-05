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

resource "libvirt_domain" "static_vm" {
  name = "static_vm"
}

