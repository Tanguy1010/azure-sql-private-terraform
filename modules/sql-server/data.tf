data "azurerm_client_config" "current" {}

data "azuread_users" "users" {
  user_principal_names = var.admin_users
}

data "azuread_group" "directory_reader" {
  display_name     = "AzureAD Sql access"
  security_enabled = true
}