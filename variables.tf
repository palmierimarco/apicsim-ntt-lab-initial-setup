variable "fabric_members" {
  description = "Map of nodes to add"
  type        = map(any)

  default = {
    NTT-LAB-LEAF-101 = {
      serial    = "TEP-1-101"
      node_id   = "101"
      pod_id    = "1"
      role      = "leaf"
      fabric_id = "1"
    },
    NTT-LAB-LEAF-102 = {
      serial    = "TEP-1-102"
      node_id   = "102"
      pod_id    = "1"
      role      = "leaf"
      fabric_id = "1"
    },
    NTT-LAB-SPINE-511 = {
      serial    = "TEP-1-103"
      node_id   = "511"
      pod_id    = "1"
      role      = "spine"
      fabric_id = "1"
    }
  }
}

variable "vlan_pools" {
  description = "Map of vlan pool"
  type        = map(any)

  default = {
    Physical_StaticPool = {
      alloc_mode = "static"
      from       = "vlan-2"
      to         = "vlan-4094"
    },
    L3Out_StaticPool = {
      alloc_mode = "static"
      from       = "vlan-3800"
      to         = "vlan-3900"
    }
  }
}

variable "physdom" {
  description = "Map of physdom"
  type        = map(any)

  default = {
    Physical_PhysDom = {
      pool = "Physical_StaticPool"
    }
  }
}

variable "l3dom" {
  description = "Map of l3domain"
  type        = map(any)

  default = {
    L3Out_ExtRoutedDom = {
      pool = "L3Out_StaticPool"
    }
  }
}

variable "aaep" {
  description = "Map of attachable access entity profile"
  type        = map(any)

  default = {
    Physical_AAEP = [
      "uni/phys-Physical_PhysDom",
      "uni/l3dom-L3Out_ExtRoutedDom"
    ]
  }
}

variable "link_level" {
  description = "Map of link level policy"
  type        = map(any)

  default = {
    Auto_10G = {
      auto_neg = "on"
      speed    = "10G"
    },
    NoAuto_10G = {
      auto_neg = "off"
      speed    = "10G"
    },
    Auto_1G = {
      auto_neg = "on"
      speed    = "1G"
    },
    NoAuto_1G = {
      auto_neg = "off"
      speed    = "1G"
    },
    Auto_40G = {
      auto_neg = "on"
      speed    = "40G"
    },
    NoAuto_40G = {
      auto_neg = "off"
      speed    = "40G"
    }
  }
}

variable "cdp" {
  description = "Map of cdp policy"
  type        = map(any)

  default = {
    CDP_On  = "enabled"
    CDP_Off = "disabled"
  }
}

variable "lldp" {
  description = "Map of lldp policy"
  type        = map(any)

  default = {
    LLDP_On  = "enabled"
    LLDP_Off = "disabled"
  }
}

variable "lacp" {
  description = "Map of lacp policy"
  type        = map(any)

  default = {
    LACP_Active_toNexus  = {
      mode = "active"
      ctrl = ["fast-sel-hot-stdby", "graceful-conv", "susp-individual"]
    },
    LACP_Active_toNonNexus  = {
      mode = "active"
      ctrl = ["fast-sel-hot-stdby", "susp-individual"]
    },
    Static_mode_on  = {
      mode = "off"
      ctrl = ["fast-sel-hot-stdby", "graceful-conv", "susp-individual"]
    }
  }
}

variable "vlan_scope" {
  description = "Map of vlan_scope policy"
  type        = map(any)

  default = {
    L2_VLAN_PortLocal  = "portlocal"
  }
}

variable "leaf_profile" {
  description = "Map of leaf_profile policy"
  type        = map(any)

  default = {
    Leaf-101_LeafProf  = {
      LeafSel = "Leaf-101_LeafSel"
      block = "node_block_101"
      from = "101"
      to = "101"
      IfProf = "Leaf-101_IntProf"
    },
    Leaf-102_LeafProf  = {
      LeafSel = "Leaf-102_LeafSel"
      block = "node_block_102"
      from = "102"
      to = "102"
      IfProf = "Leaf-102_IntProf"
    },
    Leaf-101-102_LeafProf  = {
      LeafSel = "Leaf-101-102_LeafSel"
      block = "node_block_101-102"
      from = "101"
      to = "102"
      IfProf = "Leaf-101-102_IntProf"
    }
  }
}

variable "vpc" {
  description = "Map of vpc policy"
  type        = map(any)

  default = {
    Leaf-101-102_vPC  = {
      switch1 = "101"
      switch2 = "102"
    }
  }
}
