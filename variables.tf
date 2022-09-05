variable "libvirt_provider_uri" {
  type = string
  default = "qemu:///system"
}

variable "topology_file" {
  type = string
  default = "topology/vms.json"
}
