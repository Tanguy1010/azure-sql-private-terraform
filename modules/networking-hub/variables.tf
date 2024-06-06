//--------------------------------------------------------------------------
// Required variables
//-------------------------------------------------------------------------

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "hub_vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}


//--------------------------------------------------------------------------
// Optional variables
//-------------------------------------------------------------------------

variable "private_dns_zone_name" {
  description = "The name of the Private DNS zone"
  type        = string
  default     = null
}

variable "create_ddos_plan" {
  description = "Create an ddos plan - Default is false"
  default     = false
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  type        = list(string)
  default     = []
}

variable "create_network_watcher" {
  description = "Controls if Network Watcher resources should be created for the Azure subscription"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  type = map(object({
    subnet_name           = string
    subnet_address_prefix = list(string)
    service_endpoints     = list(string)
    delegation = list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
    nsg_inbound_rules  = list(string)
    nsg_outbound_rules = list(string)
  }))
  default = {}
}

variable "gateway_subnet_address_prefix" {
  description = "The address prefix to use for the gateway subnet"
  default     = null
}

variable "gateway_service_endpoints" {
  description = "Service endpoints to add to the Gateway subnet"
  type        = list(string)
  default     = []
}

variable "gateway_sku_type" {
  description = "The SKU type of the Virtual Network Gateway"
  type        = string
  default     = "Basic"
}

variable "vpn_config" {
  description = "Configuration for point-to-site VPN connection"
  type = object({
    address_space = list(string)
    protocol      = list(string)
    auth_type     = list(string)
    aad_tenant    = string
    aad_audience  = string
    aad_issuer    = string
    root_certificate = string
  })
  default = null
}

variable "firewall_subnet_address_prefix" {
  description = "The address prefix to use for the Firewall subnet"
  type        = list(string)
  default     = null
}

variable "public_ip_names" {
  description = "Public ips is a list of ip names that are connected to the firewall. At least one is required."
  type        = list(string)
  default     = ["fw-public"]
}

variable "sku_name" {
  description = "SKU name of the Firewall. Possible values are `AZFW_Hub` and `AZFW_VNet`"
  type        = string
  default     = "AZFW_Hub"
}

variable "sku_tier" {
  description = "SKU tier of the Firewall. Possible values are `Premium`, `Standard` and `Basic`"
  type        = string
  default     = "Standard"
}

variable "firewall_zones" {
  description = "A collection of availability zones to spread the Firewall over"
  type        = list(string)
  default     = [1]
}

variable "firewall_service_endpoints" {
  description = "Service endpoints to add to the firewall subnet"
  type        = list(string)
  default = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureCosmosDB",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "firewall_application_rules" {
  description = "List of application rules to apply to firewall."
  type = list(object({
    name             = string,
    action           = string,
    source_addresses = list(string),
    target_fqdns     = list(string),
    protocol = object({
      type = string,
      port = string
    })
  }))
  default = []
}

variable "firewall_network_rules" {
  description = "List of network rules to apply to firewall."
  type = list(object({
    name                  = string,
    action                = string,
    source_addresses      = list(string),
    destination_ports     = list(string),
    destination_addresses = list(string),
    protocols             = list(string)
  }))
  default = []
}

variable "firewall_nat_rules" {
  description = "List of nat rules to apply to firewall."
  type = list(object({
    name                  = string, action = string,
    source_addresses      = list(string),
    destination_ports     = list(string),
    destination_addresses = list(string),
    protocols             = list(string),
    translated_address    = string,
    translated_port       = string
  }))
  default = []
}

variable "monitoring" {
  description = "Enable Monitoring"
  default     = false
}

variable "network_watcher_name" {
  description = "The name of the Network Watcher (require if monitoring is enabled)"
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "Storage account where logs will be stored (require if monitoring is enabled)"
  type        = string
  default     = ""
}

variable "log_analytics_workspace" {
  description = "Specifies the id of the Log Analytics Workspace (require if monitoring is enabled)"
  type = object({
    id           = string
    workspace_id = string
  })
  default = null
}

variable "fw_pip_diag_logs" {
  description = "Firewall Public IP Monitoring Category details for Azure Diagnostic setting"
  default     = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
}

variable "fw_diag_logs" {
  description = "Firewall Monitoring Category details for Azure Diagnostic setting"
  default     = ["AzureFirewallApplicationRule", "AzureFirewallNetworkRule", "AzureFirewallDnsProxy"]
}

variable "nsg_diag_logs" {
  description = "NSG Monitoring Category details for Azure Diagnostic setting"
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}