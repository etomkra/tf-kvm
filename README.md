# Terraform Setup with Libvirt provider

Prepared for TF excercises
Creates scaffold for VMs using json file in two ways:
- read as locals file
- read from local list
- execute external python script (as an example for future use in case of more sophisticated data manipulation scenarios)


# Supply variables
TF vars can be supplied using:
- default value in config (or in `variables.tf`)
- `-var` switch flag from cli
- `-var-file` switch flag from cli
- `terraform.tfvars` (containg key=value pairs) or `terraform.tfvars.json` files
- `.auto.tfvars` (containg key=value pairs) or `.auto.tfvars.json` files
- using env variables `TF_VAR_variable_name`

## Variables precedence:
`TF_VAR` > `.tfvars` > `.auto.tfvars` > `-var-file` > `-var` > cli

## Create multiple VMs
NUmber of VMs can be defined in topology/vms.json
In next releases file will be enriched, and will provide dynamic network configuration
