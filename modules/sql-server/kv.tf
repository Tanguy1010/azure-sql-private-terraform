resource "azurerm_key_vault_secret" "sql_password" {
  name         = var.sql_password_secret_name
  value        = random_password.sql_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "connection_string_sp" {
  name         = var.connection_string_sp_secret_name
  value        = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Persist Security Info=False;User ID=${azurerm_mssql_server.sql_server.administrator_login};Password=${random_password.sql_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_access_policy" "SQL_SP_access" {
  count        = var.sp_migration_object_id != "" ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.sp_migration_object_id

  secret_permissions = ["Get", "List"]
}