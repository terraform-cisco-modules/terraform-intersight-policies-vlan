#____________________________________________________________
#
# Collect the moid of the VLAN Policy as an Output
#____________________________________________________________

output "moid" {
  description = "VLAN Policy Managed Object ID (moid)."
  value       = intersight_fabric_eth_network_policy.vlan.moid
}

#____________________________________________________________
#
# Collect the moid of the VLAN Policy - Add VLANs as Outputs
#____________________________________________________________

output "vlan_moids" {
  description = "VLAN Policy - Add VLANs Managed Object ID (moid)."
  value       = { for v in sort(keys(intersight_fabric_vlan.vlans)) : v => intersight_fabric_vlan.vlans[v].moid }
}
