resource "azurerm_private_endpoint" "sql_endpoint" {
  count               = var.private_endpoint != null ? 1 : 0
  name                = "${var.name_prefix}-sql-private"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "private-serviceconnection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.name_prefix}-dns-zone-group"
    private_dns_zone_ids = [var.private_endpoint.private_dns_id]
  }

}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  count                 = var.private_endpoint != null ? 1 : 0
  name                  = "${azurerm_mssql_server.sql_server.name}-link"
  resource_group_name   = var.private_endpoint.private_dns_rg
  private_dns_zone_name = var.private_endpoint.private_dns_name
  virtual_network_id    = var.private_endpoint.vnet_id
}

resource "azurerm_private_dns_a_record" "dns_record" {
  count               = var.private_endpoint != null ? 1 : 0
  name                = azurerm_mssql_server.sql_server.name
  zone_name           = var.private_endpoint.private_dns_name
  resource_group_name = var.private_endpoint.private_dns_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_endpoint[0].private_service_connection[0].private_ip_address]
}
