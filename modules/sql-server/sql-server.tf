resource "azuread_group" "sql_admin" {
  display_name     = "${var.name_prefix}-sql-server-admin"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true

  members = data.azuread_users.users.object_ids
}

resource "azurerm_mssql_server" "sql_server" {
  name                          = lower("${var.name_prefix}-server-sql")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.sql_version
  administrator_login           = var.admin_login
  administrator_login_password  = random_password.sql_password.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  azuread_administrator {
    login_username = azuread_group.sql_admin.display_name
    object_id      = azuread_group.sql_admin.object_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "random_password" "sql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.public_network_access_enabled ? 1 : 0
  name             = "AllowAccessAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azuread_group_member" "directory_reader" {
  group_object_id  = data.azuread_group.directory_reader.object_id
  member_object_id = azurerm_mssql_server.sql_server.identity.0.principal_id
}