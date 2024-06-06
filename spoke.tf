resource "azurerm_resource_group" "spoke_rg" {
  name     = "spoke-networking-rg"
  location = var.location
  tags = var.tags
}


module "Spoke" {
  source = "./modules/networking-spoke"

  resource_group_name    = azurerm_resource_group.spoke_rg.name
  location               = azurerm_resource_group.spoke_rg.location
  spoke_vnet_name        = var.spoke_name
  vnet_address_space     = ["10.1.0.0/16"]
  hub_virtual_network_id = module.Hub.virtual_network_id

  use_remote_gateways = true
  subnets = {
    sql_subnet = {
      subnet_name           = "sql-server"
      subnet_address_prefix = ["10.1.1.0/24"]
      service_endpoints     = []
      delegation            = []
      nsg_inbound_rules     = []
      nsg_outbound_rules    = []
    }
  }

  tags = var.tags
}