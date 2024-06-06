output "sql_server_id" {
  value       = var.sql_server.id
  description = "Te SQL server ID of the database"
}

output "sql_database_id" {
  value       = azurerm_mssql_database.db.id
  description = "Te SQL database ID"
}

output "sql_database_name" {
  value       = azurerm_mssql_database.db.name
  description = "The SQL Database name"
}

output "sql_connection_string" {
  value       = "Server=tcp:${var.sql_server.domain},1433;Initial Catalog=${azurerm_mssql_database.db.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Managed Identity;Database=${azurerm_mssql_database.db.name}"
  description = "The SQL database connection string"
}