
# Vnet and Subnets
output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.name, [""]), 0)
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.id, [""]), 0)
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = element(coalescelist(azurerm_virtual_network.vnet.*.address_space, [""]), 0)
}

output "subnet_ids" {
  description = "List of IDs of subnets"
  value       = merge({ for k, v in var.subnets : k => azurerm_subnet.snet[k].id }, var.gateway_subnet_address_prefix != null ? { "gateway_subnet" = azurerm_subnet.gw_snet.0.id } : {}, var.firewall_subnet_address_prefix != null ? { "firewall_subnet" = azurerm_subnet.fw-snet[0].id } : {})
}

output "subnet_address_prefixes" {
  description = "List of address prefix for subnets"
  value       = merge({ for k, v in var.subnets : k => azurerm_subnet.snet[k].address_prefixes }, var.gateway_subnet_address_prefix != null ? { "gateway_subnet" = azurerm_subnet.gw_snet.0.address_prefixes } : {}, var.firewall_subnet_address_prefix != null ? { "firewall_subnet" = azurerm_subnet.fw-snet[0].address_prefixes } : {})
}

# Network Security group ids
output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = [for n in azurerm_network_security_group.nsg : n.id]
}

# DDoS Protection Plan
output "ddos_protection_plan_id" {
  description = "Ddos protection plan details"
  value       = var.create_ddos_plan ? element(concat(azurerm_network_ddos_protection_plan.ddos.*.id, [""]), 0) : null
}

output "route_table_name" {
  description = "The name of the route table"
  value       = azurerm_route_table.rtout.name
}

output "route_table_id" {
  description = "The resource id of the route table"
  value       = azurerm_route_table.rtout.id
}

output "private_dns_zone_name" {
  description = "The name of the Private DNS zones within Azure DNS"
  value       = var.private_dns_zone_name != null ? azurerm_private_dns_zone.dz[0].name : null
}

output "private_dns_zone_id" {
  description = "The resource id of Private DNS zones within Azure DNS"
  value       = var.private_dns_zone_name != null ? azurerm_private_dns_zone.dz[0].id : null
}

output "public_ip_prefix_id" {
  description = "The id of the Public IP Prefix resource"
  value       = var.firewall_subnet_address_prefix != null ? azurerm_public_ip_prefix.pip_prefix[0].id : null
}

output "firewall_public_ip" {
  description = "the public ip of firewall."
  value       = var.firewall_subnet_address_prefix != null ? element(concat([for ip in azurerm_public_ip.fw-pip[0] : ip.ip_address], [""]), 0) : null
}

output "firewall_public_ip_fqdn" {
  description = "Fully qualified domain name of the A DNS record associated with the public IP."
  value       = var.firewall_subnet_address_prefix != null ? element(concat([for f in azurerm_public_ip.fw-pip[0] : f.fqdn], [""]), 0) : null
}

output "firewall_private_ip" {
  description = "The private ip of firewall."
  value       = var.firewall_subnet_address_prefix != null ? azurerm_firewall.fw[0].ip_configuration.0.private_ip_address : null
}

output "firewall_id" {
  description = "The Resource ID of the Azure Firewall."
  value       = var.firewall_subnet_address_prefix != null ? azurerm_firewall.fw[0].id : null
}

output "firewall_name" {
  description = "The name of the Azure Firewall."
  value       = var.firewall_subnet_address_prefix != null ? azurerm_firewall.fw[0].name : null
}