data "azuread_groups" "groups_readers" {
  count            = var.database_readers != [] ? 1 : 0
  display_names    = var.database_readers
  security_enabled = true
}

data "azuread_groups" "groups_contributors" {
  count            = var.database_readers != [] ? 1 : 0
  display_names    = var.database_contributors
  security_enabled = true
}