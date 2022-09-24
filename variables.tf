#____________________________________________________________
#
# UCS VLAN Policy Variables Section.
#____________________________________________________________

variable "description" {
  default     = ""
  description = "Description for the Policy."
  type        = string
}

variable "name" {
  default     = "default"
  description = "Name for the Policy."
  type        = string
}

variable "organization" {
  default     = "default"
  description = "Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/."
  type        = string
}

variable "profiles" {
  default     = []
  description = "List of UCS Domain Profile Moids to Assign to the Policy."
  type        = list(string)
}

variable "tags" {
  default     = []
  description = "List of Tag Attributes to Assign to the Policy."
  type        = list(map(string))
}

#____________________________________________________________
#
# VSAN Policy -> Add VSAN Variables Section.
#____________________________________________________________

variable "vlan_list" {
  default     = []
  description = <<-EOT
    * auto_allow_on_uplinks: (optional - default is true) - Used to determine whether this VLAN will be allowed on all uplink ports and PCs in this 
    * multicast_policy: (required) - Name of the Multicast Policy to assign to the VLAN.
    * name: (optional) - The 'name' used to identify this VLAN.  When configuring with a single VLAN this will be used as the Name.  When configuring multiple VLANs the name will be used as a Name Prefix.
    * native_vlan: (optional - default is false) - Used to define whether this VLAN is to be classified as 'native' for traffic in this FI.
    * vlan_list: (required) -  This can either be one vlan like "10" or a list of VLANs: "1,10,20-30".
  EOT
  type = list(object({
    auto_allow_on_uplinks = optional(bool, true)
    multicast_policy      = string
    name                  = optional(string, "")
    native_vlan           = optional(bool, false)
    vlan_list             = string
  }))
}
