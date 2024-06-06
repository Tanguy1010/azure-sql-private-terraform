#---------------------------------------------------------------
# Network security group - NSG created for every subnet in VNet
#---------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = lower("nsg_${each.key}_in")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  dynamic "security_rule" {
    for_each = concat(lookup(each.value, "nsg_inbound_rules", []), lookup(each.value, "nsg_outbound_rules", []))
    content {
      name                       = security_rule.value[0] == "" ? "Default_Rule" : security_rule.value[0]
      priority                   = security_rule.value[1]
      direction                  = security_rule.value[2] == "" ? "Inbound" : security_rule.value[2]
      access                     = security_rule.value[3] == "" ? "Allow" : security_rule.value[3]
      protocol                   = security_rule.value[4] == "" ? "Tcp" : security_rule.value[4]
      source_port_range          = "*"
      destination_port_range     = security_rule.value[5] == "" ? "*" : security_rule.value[5]
      source_address_prefix      = security_rule.value[6] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[6]
      destination_address_prefix = security_rule.value[7] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[7]
      description                = "${security_rule.value[2]}_Port_${security_rule.value[5]}"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

#-------------------------------------------------
# route_table to dirvert traffic through Firewall
#-------------------------------------------------
resource "azurerm_route_table" "rtout" {
  name                = lower("${var.spoke_vnet_name}-spoke-rt")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_route_table_association" "rtassoc" {
  for_each       = var.subnets
  subnet_id      = azurerm_subnet.snet[each.key].id
  route_table_id = azurerm_route_table.rtout.id
}

resource "azurerm_route" "rt" {
  count                  = var.hub_firewall_private_ip_address != null ? 1 : 0
  name                   = lower("route-to-firewall-${var.spoke_vnet_name}")
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rtout.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_firewall_private_ip_address
}

#---------------------------------------------
# Linking Spoke Vnet to Hub Private DNS Zone
#---------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "dzvlink" {
  count                 = var.private_dns_zone_name != null ? 1 : 0
  name                  = lower("${var.private_dns_zone_name}-link-to-hub")
  resource_group_name   = element(split("/", var.hub_virtual_network_id), 4)
  virtual_network_id    = azurerm_virtual_network.vnet.id
  private_dns_zone_name = var.private_dns_zone_name
  registration_enabled  = true
  tags                  = var.tags
}

#--------------------------------------------
# Ddos protection plan - Default is "false"
#--------------------------------------------
resource "azurerm_network_ddos_protection_plan" "ddos" {
  count               = var.create_ddos_plan ? 1 : 0
  name                = lower("${var.spoke_vnet_name}-ddos-protection-plan")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}