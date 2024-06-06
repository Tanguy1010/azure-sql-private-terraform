//--------------------------------------------------------------------------
// Required variables
//-------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix use to create the resources"
}

variable "resource_group_name" {
  description = "Resource group name."
}

variable "admin_users" {
  description = "List of admin users"
  type        = list(string)
}

variable "admin_login" {
  type        = string
  description = "The administrator login name for the SQL Server."
}

variable "key_vault_id" {
  description = "The ID of the Key Vault where the connection string will be stored."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

//--------------------------------------------------------------------------
// Optional variables
//-------------------------------------------------------------------------

variable "location" {
  description = "Cloud datacenter Region"
  default     = "West Europe"
}

variable "sql_version" {
  description = "SQL Server version"
  default     = "12.0"
}

variable "connection_string_sp_secret_name" {
  type        = string
  description = "The name of the secret in the Key Vault that contains the SQL Server connection string."
}


variable "sql_password_secret_name" {
  type        = string
  description = "The name of the secret in the Key Vault that contains the SQL Server password."
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this server."
  default     = true
}

variable "private_endpoint" {
  type = object({
    vnet_id          = string
    subnet_id        = string
    private_dns_name = string
    private_dns_id   = string
    private_dns_rg   = string
  })
  description = "This configure a private endpoint for private access to the SQL Server."
  default     = null
}

variable "sp_migration_object_id" {
  description = "The object ID of the service principal used to migrate the database."
  type        = string
  default     = ""
}