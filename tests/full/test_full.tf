data "intersight_organization_organization" "org_moid" {
  name = "terratest"
}

module "multicast" {
  source  = "terraform-cisco-modules/policies-multicast/intersight"
  version = ">= 1.0.2"

  name         = var.name
  organization = "terratest"
}

module "main" {
  source       = "../.."
  description  = "${var.name} VLAN Policy."
  moids        = true
  name         = var.name
  organization = data.intersight_organization_organization.org_moid.results[0].moid
  policies = {
    multicast = {
      "${var.name}" = {
        moid = module.multicast.moid
      }
    }
  }
  vlans = [
    {
      multicast_policy = var.name
      name             = "other"
      vlan_list        = "2-5"
    }
  ]
}

output "multicast" {
  value = module.multicast.moid
}

output "vlan" {
  value = module.main.vlans["2"]
}