#----------------------------------------------
# Azure Virtual Gateway 
#----------------------------------------------

resource "azurerm_public_ip" "hub-vpn-gateway1-pip" {
  count               = var.gateway_subnet_address_prefix != null ? 1 : 0
  name                = lower("${var.hub_vnet_name}-pip-vpn")
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = var.gateway_sku_type == "Basic" ? "Basic" : "Standard"

  allocation_method = var.gateway_sku_type == "Basic" ? "Dynamic" : "Static"
}

resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
  count               = var.gateway_subnet_address_prefix != null ? 1 : 0
  name                = lower("${var.hub_vnet_name}-vpn")
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = var.gateway_sku_type

  tags = var.tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub-vpn-gateway1-pip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw_snet[0].id
  }

  custom_route {
    address_prefixes = []
  }

  dynamic "vpn_client_configuration" {
    for_each = var.vpn_config != null ? [var.vpn_config] : []
    content {
      address_space        = vpn_client_configuration.value.address_space
      vpn_client_protocols = vpn_client_configuration.value.protocol
      vpn_auth_types       = vpn_client_configuration.value.auth_type
      aad_tenant           = vpn_client_configuration.value.aad_tenant
      aad_audience         = vpn_client_configuration.value.aad_audience
      aad_issuer           = vpn_client_configuration.value.aad_issuer
      dynamic "root_certificate" {
        for_each = vpn_client_configuration.value.root_certificate != null ? [vpn_client_configuration.value.root_certificate] : []
        content {
          name     = "public-root-cert"
          public_cert_data = root_certificate.value
        }
      }
    }
  }

  depends_on = [azurerm_public_ip.hub-vpn-gateway1-pip]
}