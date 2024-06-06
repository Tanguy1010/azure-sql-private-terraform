module "sql_database" {
  source              = "./modules/sql-database"
  database_name       = "sql-database"
  resource_group_name = azurerm_resource_group.sql_rg.name
  location            = azurerm_resource_group.sql_rg.location
  sql_server = {
    id             = module.sql_server_private.sql_server_id
    admin_login    = module.sql_server_private.sql_admin_login
    admin_password = module.sql_server_private.sql_admin_password
    domain         = module.sql_server_private.sql_server_fqdn
  }
  max_size_gb       = 32
  sku_name          = "GP_Gen5_2"
  server_private_ip = module.sql_server_private.sql_server_id
  tags              = var.tags
}