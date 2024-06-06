variable "location" {
  description = "The location/region where the resource group will be created"
  type        = string
}

variable "admin_user" {
  description = "A user that will be added as admin of the SQL Server"
  type        = string
}

variable "hub_name" {
  description = "The name of the hub network"
  type        = string
  default = "hub-networking"
}

variable "spoke_name" {
  description = "The name of the spoke network"
  type        = string
  default = "spoke-networking"
}

variable "sql_server_name" {
  description = "The name of the SQL Server"
  type        = string
  default     = "sql-server"
}

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
  default     = "kv-sql-server"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}