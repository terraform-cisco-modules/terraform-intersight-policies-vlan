<!-- BEGIN_TF_DOCS -->
# Terraform Intersight Policies - VLAN
Manages Intersight VLAN Policies

Location in GUI:
`Policies` » `Create Policy` » `VLAN`

## Example

### main.tf
```hcl
module "vlan" {
  source  = "terraform-cisco-modules/policies-vlan/intersight"
  version = ">= 1.0.1"

  description  = "default VLAN Policy."
  name         = "default"
  organization = "default"
  vlan_list = [
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
  secretkey = var.secretkey
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
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

### Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

### Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey="<secret-key-file-location>""
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Intersight URL. | `string` | `"https://intersight.com"` | no |
| <a name="input_secretkey"></a> [secretkey](#input\_secretkey) | Intersight Secret Key. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | List of UCS Domain Profile Moids to Assign to the Policy. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
| <a name="input_vlans"></a> [vlans](#input\_vlans) | * auto\_allow\_on\_uplinks: (optional - default is true) - Used to determine whether this VLAN will be allowed on all uplink ports and PCs in this <br>* multicast\_policy: (required) - Name of the Multicast Policy to assign to the VLAN.<br>* name: (optional) - The 'name' used to identify this VLAN.  When configuring with a single VLAN this will be used as the Name.  When configuring multiple VLANs the name will be used as a Name Prefix.<br>* native\_vlan: (optional - default is false) - Used to define whether this VLAN is to be classified as 'native' for traffic in this FI.<br>* vlan\_list: (required) -  This can either be one vlan like "10" or a list of VLANs: "1,10,20-30". | <pre>list(object({<br>    auto_allow_on_uplinks = optional(bool, true)<br>    multicast_policy      = string<br>    name                  = optional(string, "")<br>    native_vlan           = optional(bool, false)<br>    vlan_list             = string<br>  }))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | VLAN Policy Managed Object ID (moid). |
| <a name="output_vlan_moids"></a> [vlan\_moids](#output\_vlan\_moids) | VLAN Policy - Add VLANs Managed Object ID (moid). |
## Resources

| Name | Type |
|------|------|
| [intersight_fabric_eth_network_policy.vlan](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fabric_eth_network_policy) | resource |
| [intersight_fabric_vlan.vlans](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fabric_vlan) | resource |
| [intersight_fabric_multicast_policy.multicast](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_multicast_policy) | data source |
| [intersight_fabric_switch_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_switch_profile) | data source |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
<!-- END_TF_DOCS -->