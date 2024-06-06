//--------------------------------------------------------------------------
// Required variables
//-------------------------------------------------------------------------

variable "database_name" {
  description = "The name of the database to create."
}

variable "resource_group_name" {
  description = "Resource group name."
}

variable "sql_server" {
  description = "The SQL server to connect to."
  type = object({
    id = string
    admin_login = string
    admin_password = string
    domain = string
  })
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

variable "max_size_gb" {
  description = "The maximum size of the database in gigabytes."
  type        = number
  default     = 32
}

variable "sku_name" {
  description = "The name of the SKU used by the database."
  type        = string
  default     = "GP_Gen5_2"
}

variable "identity_access" {
  description = "Grant Azure identity access to sql database. (For system assigned use : data 'azuread_service_principal' => client_id)"
  type = list(object({
    name      = string
    object_id = string
    roles     = list(string)
  }))
  default = []
}

variable "zone_redundant" {
  description = "Enable zone redundancy"
  type        = bool
  default     = false
}

variable "database_readers" {
  description = "List of groups to grant read access to the database."
  type        = list(string)
  default     = []
}

variable "database_contributors" {
  description = "List of groups to grant read and write access to the database."
  type        = list(string)
  default     = []
}

variable "server_private_ip" {
  description = "if the server is private, the private ip address to connect to the server."
  type        = string
  default     = ""
}