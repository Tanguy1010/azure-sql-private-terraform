resource "azurerm_resource_group" "sql_rg" {
  name     = "sql-rg"
  location = var.location
  tags = var.tags
}

module "sql_server_private" {
  source                 = "./modules/sql-server"
  name_prefix            = var.sql_server_name
  resource_group_name    = azurerm_resource_group.sql_rg.name
  location               = azurerm_resource_group.sql_rg.location
  admin_login            = "MSSQLAdmin"
  admin_users            = [var.admin_user]
  key_vault_id           = azurerm_key_vault.keyvault_sql.id

  public_network_access_enabled = false

  private_endpoint = {
    vnet_id          = module.Spoke.virtual_network_id
    subnet_id        = module.Spoke.subnet_ids["sql_subnet"]
    private_dns_name = azurerm_private_dns_zone.sql_dns.name
    private_dns_id   = azurerm_private_dns_zone.sql_dns.id
    private_dns_rg   = azurerm_private_dns_zone.sql_dns.resource_group_name
  }

  sql_password_secret_name         = "AdminPassword"
  connection_string_sp_secret_name = "SQLConnectionString"

  tags = var.tags
}