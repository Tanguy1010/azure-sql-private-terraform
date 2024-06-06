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
  value       = { for k, v in var.subnets : k => azurerm_subnet.snet[k].id }
}

output "subnet_address_prefixes" {
  description = "List of address prefix for subnets"
  value       = { for k, v in var.subnets : k => azurerm_subnet.snet[k].address_prefixes }
}

output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = [for n in azurerm_network_security_group.nsg : n.id]
}

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