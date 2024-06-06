resource "azurerm_key_vault" "keyvault_sql" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.sql_rg.location
  resource_group_name         = azurerm_resource_group.sql_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  tags                        = var.tags
  enabled_for_deployment      = true

  sku_name = "standard"

}

resource "azurerm_key_vault_access_policy" "access" {
  key_vault_id = azurerm_key_vault.keyvault_sql.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]
  key_permissions = []
  certificate_permissions = []
}