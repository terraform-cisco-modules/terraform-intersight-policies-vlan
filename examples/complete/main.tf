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
