locals {
  fw_nat_rules = { for idx, rule in var.firewall_nat_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }

  fw_network_rules = { for idx, rule in var.firewall_network_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }

  fw_application_rules = { for idx, rule in var.firewall_application_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }
  public_ip_map = { for pip in var.public_ip_names : pip => true }
}

#--------------------------------------------
# Ddos protection plan - Default is "true"
#--------------------------------------------
resource "azurerm_network_ddos_protection_plan" "ddos" {
  count               = var.create_ddos_plan ? 1 : 0
  name                = lower("${var.hub_vnet_name}-ddos-protection-plan")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

#---------------------------------------------------------------
# Network security group - NSG created for every subnet in VNet
#---------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = lower("${each.key}_nsg_in")
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
  name                = lower("${var.hub_vnet_name}-hub-rt")
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
  count                  = var.firewall_subnet_address_prefix != null ? 1 : 0
  name                   = lower("${var.hub_vnet_name}-route-to-firewall")
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rtout.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.fw[0].ip_configuration.0.private_ip_address
}

#------------------------------------------
# Public IP resources for Azure Firewall
#------------------------------------------
resource "random_string" "str" {
  for_each = local.public_ip_map
  length   = 6
  special  = false
  upper    = false
  keepers = {
    domain_name_label = each.key
  }
}

resource "azurerm_public_ip_prefix" "pip_prefix" {
  count               = var.firewall_subnet_address_prefix != null ? 1 : 0
  name                = lower("${var.hub_vnet_name}-pip-prefix")
  location            = var.location
  resource_group_name = var.resource_group_name
  prefix_length       = 30
  tags                = var.tags
}

resource "azurerm_public_ip" "fw-pip" {
  for_each            = var.firewall_subnet_address_prefix != null ? local.public_ip_map : {}
  name                = lower("${var.hub_vnet_name}-pip-${each.key}")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = azurerm_public_ip_prefix.pip_prefix[0].id
  domain_name_label   = format("%s%s", lower(replace(each.key, "/[[:^alnum:]]/", "")), random_string.str[each.key].result)
  tags                = var.tags
}
#-----------------
# Azure Firewall 
#-----------------
resource "azurerm_firewall" "fw" {
  count               = var.firewall_subnet_address_prefix != null ? 1 : 0
  name                = lower("${var.hub_vnet_name}-fw")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  zones               = var.firewall_zones
  tags                = var.tags
  dynamic "ip_configuration" {
    for_each = local.public_ip_map
    iterator = ip
    content {
      name                 = ip.key
      subnet_id            = ip.key == var.public_ip_names[0] ? azurerm_subnet.fw-snet.id : null
      public_ip_address_id = azurerm_public_ip.fw-pip[ip.key].id
    }
  }
}

#----------------------------------------------
# Azure Firewall Network/Application/NAT Rules 
#----------------------------------------------
resource "azurerm_firewall_application_rule_collection" "fw_app" {
  for_each            = local.fw_application_rules
  name                = lower(format("fw-app-rule-%s-${var.hub_vnet_name}", each.key))
  azure_firewall_name = azurerm_firewall.fw[0].name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name             = each.key
    source_addresses = each.value.rule.source_addresses
    target_fqdns     = each.value.rule.target_fqdns

    protocol {
      type = each.value.rule.protocol.type
      port = each.value.rule.protocol.port
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "fw" {
  for_each            = local.fw_network_rules
  name                = lower(format("fw-net-rule-%s-${var.hub_vnet_name}", each.key))
  azure_firewall_name = azurerm_firewall.fw[0].name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name                  = each.key
    source_addresses      = each.value.rule.source_addresses
    destination_ports     = each.value.rule.destination_ports
    destination_addresses = [for dest in each.value.rule.destination_addresses : contains(var.public_ip_names, dest) ? azurerm_public_ip.fw-pip[dest].ip_address : dest]
    protocols             = each.value.rule.protocols
  }
}

resource "azurerm_firewall_nat_rule_collection" "fw" {
  for_each            = local.fw_nat_rules
  name                = lower(format("fw-nat-rule-%s-${var.hub_vnet_name}", each.key))
  azure_firewall_name = azurerm_firewall.fw[0].name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name                  = each.key
    source_addresses      = each.value.rule.source_addresses
    destination_ports     = each.value.rule.destination_ports
    destination_addresses = [for dest in each.value.rule.destination_addresses : contains(var.public_ip_names, dest) ? azurerm_public_ip.fw-pip[dest].ip_address : dest]
    protocols             = each.value.rule.protocols
    translated_address    = each.value.rule.translated_address
    translated_port       = each.value.rule.translated_port
  }
}