#---------------------------------
# Local declarations
#---------------------------------
locals {
  if_ddos_enabled     = var.create_ddos_plan ? [{}] : []
}

#-------------------------------------
# VNET Creation 
#-------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = lower("${var.spoke_vnet_name}-spoke-vnet")
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = local.if_ddos_enabled

    content {
      id     = azurerm_network_ddos_protection_plan.ddos[0].id
      enable = true
    }
  }

  lifecycle {
    ignore_changes = [
      subnet
    ]
  }
}

#--------------------------------------------------------------------------------------------------------
# Subnets Creation with, private link endpoint/servie network policies, service endpoints and Deligation.
#--------------------------------------------------------------------------------------------------------
resource "azurerm_subnet" "snet" {
  for_each             = var.subnets
  name                 = lower("${each.value.subnet_name}-subnet")
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.subnet_address_prefix
  service_endpoints    = lookup(each.value, "service_endpoints", [])
  # Applicable to the subnets which used for Private link endpoints or services 
  private_endpoint_network_policies_enabled     = lookup(each.value, "private_endpoint_network_policies_enabled", null)
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", null)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

#-----------------------------------------------
# Peering between Hub and Spoke Virtual Network
#-----------------------------------------------
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = lower("peering-to-hub-${element(split("/", var.hub_virtual_network_id), 8)}")
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = var.hub_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = lower("peering-${element(split("/", var.hub_virtual_network_id), 8)}-to-spoke")
  resource_group_name          = element(split("/", var.hub_virtual_network_id), 4)
  virtual_network_name         = element(split("/", var.hub_virtual_network_id), 8)
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_gateway_transit        = true
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = false
}

#-----------------------------------------------
# Peering between other Spokes
#-----------------------------------------------

resource "azurerm_virtual_network_peering" "this_to_spoke" {
  for_each                     = var.peering_spokes_id
  name                         = lower("peering-${azurerm_virtual_network.vnet.name}-to-${element(split("/", each.value), 8)}")
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = each.value
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_this" {
  for_each                     = var.peering_spokes_id
  name                         = lower("peering-${element(split("/", each.value), 8)}-to-${azurerm_virtual_network.vnet.name}")
  resource_group_name          = element(split("/", each.value), 4)
  virtual_network_name         = element(split("/", each.value), 8)
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# TODO If we want to have hub and spoke in different subscription
#resource "azurerm_virtual_network_peering" "hub_to_spoke" {
#  provider                     = azurerm.hub
#  name                         = lower("peering-${element(split("/", var.hub_virtual_network_id), 8)}-to-spoke")
#  resource_group_name          = element(split("/", var.hub_virtual_network_id), 4)
#  virtual_network_name         = element(split("/", var.hub_virtual_network_id), 8)
#  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
#  allow_gateway_transit        = true
#  allow_forwarded_traffic      = true
#  allow_virtual_network_access = true
#  use_remote_gateways          = false
#}