resource "azurerm_resource_group" "hub_rg" {
  name     = "hub-networking-rg"
  location = var.location
  tags     = var.tags
}

module "Hub" {
  source = "./modules/networking-hub"

  resource_group_name = azurerm_resource_group.hub_rg.name
  location            = azurerm_resource_group.hub_rg.location
  hub_vnet_name       = var.hub_name

  vnet_address_space            = ["10.0.0.0/16"]
  gateway_subnet_address_prefix = ["10.0.1.0/27"]
  gateway_sku_type              = "VpnGw1"

  subnets = {
    resolver_subnet = {
      subnet_name           = "dns-resolver"
      subnet_address_prefix = ["10.0.2.0/24"]
      service_endpoints     = []
      delegation = [{
        name = "dns-resolver-delegation"
        service_delegation = {
          name    = "Microsoft.Network/dnsResolvers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
      nsg_inbound_rules  = []
      nsg_outbound_rules = []
    }
  }

  tags = var.tags
}

resource "azurerm_private_dns_resolver" "dns_resolver" {
  name                = "hub-dns-resolver"
  resource_group_name = azurerm_resource_group.hub_rg.name
  location            = azurerm_resource_group.hub_rg.location
  virtual_network_id  = module.Hub.virtual_network_id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "resolver_inbound" {
  name                    = "inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  location                = azurerm_private_dns_resolver.dns_resolver.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = module.Hub.subnet_ids["resolver_subnet"]
  }
}

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.hub_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "hub-dns-link"
  resource_group_name   = azurerm_resource_group.hub_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = module.Hub.virtual_network_id
}