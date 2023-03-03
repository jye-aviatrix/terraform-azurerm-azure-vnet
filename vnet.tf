resource "azurerm_virtual_network" "this" {
  resource_group_name = var.resource_group_name
  location            = var.vNet_config.location
  address_space       = var.vNet_config.address_space
  name                = var.vNet_config.name
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

resource "azurerm_subnet" "this" {
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  for_each             = var.vNet_config.subnets
  name                 = each.key
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_route_table" "this" {
  resource_group_name           = var.resource_group_name
  location                      = var.vNet_config.location
  for_each                      = { for k, v in var.vNet_config.subnets : k => v if try(v.udr, false) } # Only create UDR when UDR is set to true, will not create UDR if not set
  name                          = "${var.vNet_config.name}-${each.key}"
  disable_bgp_route_propagation = try(each.value.disable_bgp_route_propagation, false) ? true : false # Only disable Propagate Gateway Route when explicity set disable_bgp_route_propagation to true

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = each.value.is_public_subnet ? "Internet" : var.egress_nva != "" ? "VirtualAppliance" : "None"
    next_hop_in_ip_address = each.value.is_public_subnet ? null : var.egress_nva != "" ? var.egress_nva : null
  }

  dynamic "route" {
    for_each = var.ew_nva != "" ? [1] : []
    content {
      name                   = "10-8"
      address_prefix         = "10.0.0.0/8"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.ew_nva
    }
  }

  dynamic "route" {
    for_each = var.ew_nva != "" ? [1] : []
    content {
      name                   = "172-12"
      address_prefix         = "172.16.0.0/12"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.ew_nva
    }
  }

  dynamic "route" {
    for_each = var.ew_nva != "" ? [1] : []
    content {
      name                   = "192-16"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.ew_nva
    }
  }

}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = { for k, v in var.vNet_config.subnets : k => v if try(v.udr, false) } # Only associate UDR when UDR is set to true, will not associate if UDR not set
  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.key].id
}
