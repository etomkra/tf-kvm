variable "libvirt_provider_uri" {
  type = string
  default = "qemu:///system"
}

variable "topology_file" {
  type = string
  default = "topology/vms.json"
}

variable "vm_root_pass" {
  type = string
  sensitive = true
}

variable "fixed_vm_list" {
  type = list(string)
  description = "Fixed VM Name list"
  default = ["vm-1-var", "vm-2-var"]
}
