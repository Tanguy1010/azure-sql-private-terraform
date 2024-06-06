#-----------------------------------------
# Network flow logs for subnet and NSG
#-----------------------------------------
resource "azurerm_network_watcher_flow_log" "nwflog" {
  for_each                  = var.monitoring == true ? var.subnets : {}
  name                      = lower("network-watcher-flow-log")
  network_watcher_name      = var.network_watcher_name
  resource_group_name       = var.resource_group_name # Must provide Netwatcher resource Group
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
  storage_account_id        = var.hub_storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = 0
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_customer_id
    workspace_region      = var.location
    workspace_resource_id = var.log_analytics_workspace_id
    interval_in_minutes   = 10
  }
}

#---------------------------------------------------------------
# azurerm monitoring diagnostics - VNet, NSG, PIP, and Firewall
#---------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "vnet" {
  count                      = var.monitoring ? 1 : 0
  name                       = lower("vnet-${var.spoke_vnet_name}-diag")
  target_resource_id         = azurerm_virtual_network.vnet.id
  storage_account_id         = var.hub_storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "VMProtectionAlerts"
  }
  metric {
    category = "AllMetrics"

  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  for_each                   = var.monitoring == true ? var.subnets : {}
  name                       = lower("${each.key}-diag")
  target_resource_id         = azurerm_network_security_group.nsg[each.key].id
  storage_account_id         = var.hub_storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.nsg_diag_logs
    content {
      category = log.value
    }
  }
}