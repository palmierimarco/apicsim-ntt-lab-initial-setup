terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

# Configure the provider with your Cisco APIC credentials.
provider "aci" {
  # APIC Username
  username = var.apic.username
  # APIC Password
  password = var.apic.password
  # APIC URL
  url      = var.apic.url
  insecure = true
}

##########################################################################

resource "aci_fabric_node_member" "member" {
  for_each  = var.fabric_members
  name      = each.key
  serial    = each.value.serial
  fabric_id = each.value.fabric_id
  node_id   = each.value.node_id
  pod_id    = each.value.pod_id
  role      = each.value.role
}

resource "aci_vlan_pool" "vlan_pool" {
  for_each   = var.vlan_pools
  name       = each.key
  alloc_mode = each.value.alloc_mode
}

resource "aci_ranges" "vlan_range" {
  for_each     = var.vlan_pools
  vlan_pool_dn = aci_vlan_pool.vlan_pool[each.key].id
  from         = each.value.from
  to           = each.value.to
  alloc_mode   = "inherit"
  role         = "external"
}

resource "aci_physical_domain" "physdom" {
  for_each                  = var.physdom
  name                      = each.key
  relation_infra_rs_vlan_ns = aci_vlan_pool.vlan_pool[each.value.pool].id
}

resource "aci_l3_domain_profile" "l3dom" {
  for_each                  = var.l3dom
  name                      = each.key
  relation_infra_rs_vlan_ns = aci_vlan_pool.vlan_pool[each.value.pool].id
}

resource "aci_attachable_access_entity_profile" "aaep" {
  depends_on              = [aci_l3_domain_profile.l3dom, aci_physical_domain.physdom]
  for_each                = var.aaep
  name                    = each.key
  relation_infra_rs_dom_p = each.value
}

resource "aci_fabric_if_pol" "link_level" {
  for_each = var.link_level
  name     = each.key
  auto_neg = each.value.auto_neg
  speed    = each.value.speed
}

resource "aci_cdp_interface_policy" "cdp" {
  for_each = var.cdp
  name     = each.key
  admin_st = each.value
}

resource "aci_lldp_interface_policy" "ldp" {
  for_each    = var.lldp
  name        = each.key
  admin_rx_st = each.value
  admin_tx_st = each.value
}

resource "aci_lacp_policy" "lacp" {
  for_each = var.lacp
  name     = each.key
  ctrl     = each.value.ctrl
  mode     = each.value.mode
}

resource "aci_l2_interface_policy" "vlan_scope" {
  for_each   = var.vlan_scope
  name       = each.key
  vlan_scope = each.value
}

resource "aci_access_switch_policy_group" "switch_policy_group" {
  name                                                   = "Default_LeafPolGrp"
  relation_infra_rs_bfd_ipv4_inst_pol                    = "uni/infra/bfdIpv4Inst-default"
  relation_infra_rs_bfd_ipv6_inst_pol                    = "uni/infra/bfdIpv6Inst-default"
  relation_infra_rs_bfd_mh_ipv4_inst_pol                 = "uni/infra/bfdMhIpv4Inst-default"
  relation_infra_rs_bfd_mh_ipv6_inst_pol                 = "uni/infra/bfdMhIpv6Inst-default"
  relation_infra_rs_equipment_flash_config_pol           = "uni/infra/flashconfigpol-default"
  relation_infra_rs_fc_fabric_pol                        = "uni/infra/fcfabricpol-default"
  relation_infra_rs_fc_inst_pol                          = "uni/infra/fcinstpol-default"
  relation_infra_rs_iacl_leaf_profile                    = "uni/infra/iaclleafp-default"
  relation_infra_rs_l2_node_auth_pol                     = "uni/infra/nodeauthpol-default"
  relation_infra_rs_leaf_copp_profile                    = "uni/infra/coppleafp-default"
  relation_infra_rs_leaf_p_grp_to_cdp_if_pol             = "uni/infra/cdpIfP-default"
  relation_infra_rs_leaf_p_grp_to_lldp_if_pol            = "uni/infra/lldpIfP-default"
  relation_infra_rs_mon_node_infra_pol                   = "uni/infra/moninfra-default"
  relation_infra_rs_mst_inst_pol                         = "uni/infra/mstpInstPol-default"
  relation_infra_rs_poe_inst_pol                         = "uni/infra/poeInstP-default"
  relation_infra_rs_topoctrl_fast_link_failover_inst_pol = "uni/infra/fastlinkfailoverinstpol-default"
  relation_infra_rs_topoctrl_fwd_scale_prof_pol          = "uni/infra/fwdscalepol-default"
}

resource "aci_leaf_interface_profile" "leaf_interface_profile" {
  for_each = var.leaf_profile
  name     = each.value.IfProf
}

resource "aci_leaf_profile" "leaf_profile" {
  for_each                     = var.leaf_profile
  name                         = each.key
  relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.leaf_interface_profile[each.key].id]
}

resource "aci_leaf_selector" "leaf_selector" {
  for_each                         = var.leaf_profile
  leaf_profile_dn                  = aci_leaf_profile.leaf_profile[each.key].id
  name                             = each.value.LeafSel
  switch_association_type          = "range"
  relation_infra_rs_acc_node_p_grp = aci_access_switch_policy_group.switch_policy_group.id
}

resource "aci_node_block" "node_block" {
  for_each              = var.leaf_profile
  switch_association_dn = aci_leaf_selector.leaf_selector[each.key].id
  name                  = each.value.block
  from_                 = each.value.from
  to_                   = each.value.to
}

resource "aci_vpc_explicit_protection_group" "vpc" {
  for_each                         = var.vpc
  name                             = each.key
  switch1                          = each.value.switch1
  switch2                          = each.value.switch2
  vpc_domain_policy                = "default"
  vpc_explicit_protection_group_id = each.value.switch1
}

data "local_file" "dns" {
  filename = "./json/dnsp-default.json"
}

resource "aci_rest" "pod_policy" {
  path       = "/api/mo/uni.json"
  class_name = "dnsProfile"
  payload    = data.local_file.dns.content
}

data "local_file" "podpgrp" {
  filename = "./json/podpgrp-default.json"
}

resource "aci_rest" "podpgrp" {
  path       = "/api/mo/uni.json"
  class_name = "fabricPodPGrp"
  payload    = data.local_file.podpgrp.content
}

data "local_file" "podprof" {
  filename = "./json/podprof-default.json"
}

resource "aci_rest" "podprof" {
  path       = "/api/mo/uni.json"
  class_name = "fabricPodP"
  payload    = data.local_file.podprof.content
}

data "local_file" "time" {
  filename = "./json/time-default.json"
}

resource "aci_rest" "time" {
  path       = "/api/mo/uni.json"
  class_name = "datetimePol"
  payload    = data.local_file.time.content
}

data "local_file" "systembgp" {
  filename = "./json/bgpInstP-default.json"
}

resource "aci_rest" "systembgp" {
  path       = "/api/mo/uni.json"
  class_name = "bgpInstPol"
  payload    = data.local_file.systembgp.content
}
