<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)
[![Tests](https://github.com/terraform-cisco-modules/terraform-intersight-policies-vlan/actions/workflows/terratest.yml/badge.svg)](https://github.com/terraform-cisco-modules/terraform-intersight-policies-vlan/actions/workflows/terratest.yml)

# Terraform Intersight Policies - VLAN
Manages Intersight VLAN Policies

Location in GUI:
`Policies` » `Create Policy` » `VLAN`

## Easy IMM

[*Easy IMM - Comprehensive Example*](https://github.com/terraform-cisco-modules/easy-imm-comprehensive-example) - A comprehensive example for policies, pools, and profiles.

## Example

### main.tf
```hcl
module "vlan" {
  source  = "terraform-cisco-modules/policies-vlan/intersight"
  version = ">= 1.0.1"

  description  = "default VLAN Policy."
  name         = "default"
  organization = "default"
  vlans = [
    {
      auto_allow_on_uplinks = true
      multicast_policy      = "default"
      name                  = "default"
      native_vlan           = true
      vlan_list             = "1"
    },
    {
      multicast_policy = "default"
      name             = "other"
      vlan_list        = "2-99"
    }
  ]
}
```

### provider.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
  required_version = ">=1.3.0"
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = fileexists(var.secretkeyfile) ? file(var.secretkeyfile) : var.secretkey
}
```

### variables.tf
```hcl
variable "apikey" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
}

variable "endpoint" {
  default     = "https://intersight.com"
  description = "Intersight URL."
  type        = string
}

variable "secretkey" {
  default     = ""
  description = "Intersight Secret Key Content."
  sensitive   = true
  type        = string
}

variable "secretkeyfile" {
  default     = "blah.txt"
  description = "Intersight Secret Key File Location."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with the value of [your-api-key]
- Add variable secretkey with the value of [your-secret-file-content]

### Linux and Windows
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkeyfile="<secret-key-file-location>"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | >=1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_domain_profiles"></a> [domain\_profiles](#input\_domain\_profiles) | Map for Moid based Domain Profile Sources. | `any` | `{}` | no |
| <a name="input_moids"></a> [moids](#input\_moids) | Flag to Determine if pools and policies should be data sources or if they already defined as a moid. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Map for Moid based Policies Sources. | `any` | `{}` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | List of UCS Domain Switch Profile Names to Assign to the Policy. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
| <a name="input_vlans"></a> [vlans](#input\_vlans) | * auto\_allow\_on\_uplinks: (optional - default is true) - Used to determine whether this VLAN will be allowed on all uplink ports and PCs in this <br>* multicast\_policy: (required) - Name of the Multicast Policy to assign to the VLAN.<br>* name: (optional) - The 'name' used to identify this VLAN.  When configuring with a single VLAN this will be used as the Name.  When configuring multiple VLANs the name will be used as a Name Prefix.<br>* native\_vlan: (optional - default is false) - Used to define whether this VLAN is to be classified as 'native' for traffic in this FI.<br>* vlan\_list: (required) -  This can either be one vlan like "10" or a list of VLANs: "1,10,20-30". | <pre>list(object({<br>    auto_allow_on_uplinks = optional(bool, true)<br>    multicast_policy      = string<br>    name                  = optional(string, "")<br>    native_vlan           = optional(bool, false)<br>    vlan_list             = string<br>  }))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | VLAN Policy Managed Object ID (moid). |
| <a name="output_vlans"></a> [vlans](#output\_vlans) | VLAN Policy - Add VLANs Managed Object ID (moid). |
## Resources

| Name | Type |
|------|------|
| [intersight_fabric_eth_network_policy.vlan](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fabric_eth_network_policy) | resource |
| [intersight_fabric_vlan.vlans](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fabric_vlan) | resource |
| [intersight_fabric_multicast_policy.multicast](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_multicast_policy) | data source |
| [intersight_fabric_switch_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_switch_profile) | data source |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
<!-- END_TF_DOCS -->