#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  for_each = {
    for v in [var.organization] : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

#____________________________________________________________
#
# Intersight UCS Domain Profile(s) Data Source
# GUI Location: Profiles > UCS Domain Profiles > {Name}
#____________________________________________________________

data "intersight_fabric_switch_profile" "profiles" {
  for_each = { for v in var.profiles : v => v if length(regexall("[[:xdigit:]]{24}", v)) == 0 }
  name     = each.value
}

#____________________________________________________________
#
# Intersight Multicast Policy Data Source
# GUI Location: Policies > Type: Multicast > {Name}
#____________________________________________________________

data "intersight_fabric_multicast_policy" "multicast" {
  for_each = {
    for v in local.multicast_policies : v => v if length(regexall("[[:xdigit:]]{24}", v)) == 0
  }
  name = each.value
}

#__________________________________________________________________
#
# Intersight VLAN Policy
# GUI Location: Policies > Create Policy > VLAN
#__________________________________________________________________

resource "intersight_fabric_eth_network_policy" "vlan" {
  depends_on = [
    data.intersight_organization_organization.org_moid,
    data.intersight_fabric_multicast_policy.multicast,
    data.intersight_fabric_switch_profile.profiles
  ]
  description = var.description != "" ? var.description : "${var.name} VLAN Policy."
  name        = var.name
  organization {
    moid = length(
      regexall("[[:xdigit:]]{24}", var.organization)
      ) > 0 ? var.organization : data.intersight_organization_organization.org_moid[
      var.organization].results[0
    ].moid
    object_type = "organization.Organization"
  }
  dynamic "profiles" {
    for_each = { for v in var.profiles : v => v }
    content {
      moid = length(
        regexall("[[:xdigit:]]{24}", profiles.value)
      ) > 0 ? profiles.value : data.intersight_fabric_switch_profile.profiles[profiles.value].results[0].moid
      object_type = "fabric.SwitchProfile"
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


#__________________________________________________________________
#
# Intersight > {VLAN Policy} > Edit  > Add VLAN
# GUI Location: Policies > Create Policy > VLAN > Add VLAN
#__________________________________________________________________

locals {
  vlans_loop_1 = {
    for k, v in var.vlans : k => {
      auto_allow_on_uplinks = v.auto_allow_on_uplinks
      multicast_policy      = v.multicast_policy
      name                  = v.name
      name_prefix           = length(regexall("(,|-)", jsonencode(v.vlan_list))) > 0 ? true : false
      native_vlan           = v.native_vlan
      vlan_list = flatten(
        [for s in compact(length(regexall("-", v.vlan_list)) > 0 ? tolist(split(",", v.vlan_list)
          ) : length(regexall(",", v.vlan_list)) > 0 ? tolist(split(",", v.vlan_list)) : [v.vlan_list]
          ) : length(regexall("-", s)) > 0 ? [for v in range(tonumber(element(split("-", s), 0)
      ), (tonumber(element(split("-", s), 1)) + 1)) : tonumber(v)] : [s]])
    }
  }

  vlans_loop_2 = flatten([
    for k, v in local.vlans_loop_1 : [
      for s in v.vlan_list : {
        auto_allow_on_uplinks = v.auto_allow_on_uplinks
        multicast_policy      = v.multicast_policy
        name                  = v.name
        name_prefix           = v.name_prefix
        native_vlan           = v.native_vlan
        vlan_id               = s
      }
    ]
  ])

  vlan_list = { for k, v in local.vlans_loop_2 : v.vlan_id => v }

  multicast_policies = toset([
    for v in local.vlans_loop_1 : v.multicast_policy
  ])
}


#__________________________________________________________________
#
# Intersight VLAN Policy > Add VLANs
# GUI Location: Policies > Create Policy > VLAN Policy > Add VLANs
#__________________________________________________________________

resource "intersight_fabric_vlan" "vlans" {
  depends_on = [
    data.intersight_fabric_multicast_policy.multicast,
    intersight_fabric_eth_network_policy.vlan
  ]
  for_each              = local.vlan_list
  auto_allow_on_uplinks = each.value.auto_allow_on_uplinks
  is_native             = each.value.native_vlan
  name = length(
    compact([each.value.name])
    ) > 0 && each.value.name_prefix == false ? each.value.name : length(
    regexall("^[0-9]{4}$", each.value.vlan_id)
    ) > 0 ? join("-vl", [each.value.name, each.value.vlan_id]) : length(
    regexall("^[0-9]{3}$", each.value.vlan_id)
    ) > 0 ? join("-vl0", [each.value.name, each.value.vlan_id]) : length(
    regexall("^[0-9]{2}$", each.value.vlan_id)
    ) > 0 ? join("-vl00", [each.value.name, each.value.vlan_id]) : join(
    "-vl000", [each.value.name, each.value.vlan_id]
  )
  vlan_id = each.value.vlan_id
  eth_network_policy {
    moid = intersight_fabric_eth_network_policy.vlan.moid
  }
  multicast_policy {
    moid = length(
      regexall("[[:xdigit:]]{24}", each.value.multicast_policy)
      ) > 0 ? each.value.multicast_policy : data.intersight_fabric_multicast_policy.multicast[
      each.value.multicast_policy].results[0
    ].moid
  }
}
