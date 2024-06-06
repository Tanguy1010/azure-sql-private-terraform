resource "azurerm_mssql_database" "db" {
  name           = var.database_name
  server_id      = var.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = var.max_size_gb
  read_scale     = false
  sku_name       = var.sku_name
  zone_redundant = var.zone_redundant

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["CreatedOn"], tags["CreatedBy"]
    ]
  }
}

resource "mssql_user" "sql_access" {
  for_each = { for identity in concat(var.identity_access, local.database_access) : identity.name => identity }
  server {
    host = var.sql_server.domain
    login {
      username = var.sql_server.admin_login
      password = var.sql_server.admin_password
    }
  }

  database  = azurerm_mssql_database.db.name
  username  = each.value.name
  object_id = each.value.object_id

  roles = each.value.roles
}