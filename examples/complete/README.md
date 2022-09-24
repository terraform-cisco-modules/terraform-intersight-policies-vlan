<!-- BEGIN_TF_DOCS -->
# VLAN Policy Example

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

### main.tf
```hcl
module "vlan_policy" {
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

### versions.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = var.secretkey
}
```
<!-- END_TF_DOCS -->