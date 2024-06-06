output "sql_server_id" {
  value       = azurerm_mssql_server.sql_server.id
  description = "The SQL Server ID"
}

output "sql_server_name" {
  value       = azurerm_mssql_server.sql_server.name
  description = "The SQL Server name"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  description = "The SQL Server FQDN"
}

output "sql_connection_string_secret_name" {
  value       = azurerm_key_vault_secret.connection_string_sp.name
  description = "Name of the SQL Server connection string secret name"
}

output "sql_password_secret_name" {
  value       = azurerm_key_vault_secret.sql_password.name
  description = "Name of the SQL Server password secret name"
}

output "sql_admin_login" {
  value       = azurerm_mssql_server.sql_server.administrator_login
  description = "The SQL Server administrator login"
}

output "sql_admin_password" {
  value       = random_password.sql_password.result
  description = "The SQL Server administrator password"
  sensitive   = true
}

output "sql_identity_id" {
  value       = azurerm_mssql_server.sql_server.identity[0].principal_id
  description = "The SQL Server SystemAssigned identity ID"
}

output "sql_private_endpoint_id" {
  value       = var.private_endpoint != null ? azurerm_private_endpoint.sql_endpoint[0].id : null
  description = "The SQL Server Private Endpoint ID"
}

output "sql_network_interface_id" {
  value       = var.private_endpoint != null ? azurerm_private_endpoint.sql_endpoint[0].network_interface[0].id : null
  description = "The SQL Server Network Interface ID"
}

output "sql_private_endpoint_ip_address" {
  value       = var.private_endpoint != null ? azurerm_private_endpoint.sql_endpoint[0].private_service_connection[0].private_ip_address : null
  description = "The SQL Server Private Endpoint IP Address"
}