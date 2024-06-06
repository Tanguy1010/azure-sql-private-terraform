locals {
  database_access = [{
    name      = azuread_group.database_reader.display_name
    object_id = azuread_group.database_reader.object_id
    roles     = ["db_datareader"]
    },
    {
      name      = azuread_group.database_contributor.display_name
      object_id = azuread_group.database_contributor.object_id
      roles     = ["db_datareader", "db_datawriter"]
  }]
}

resource "azuread_group" "database_reader" {
  display_name     = "${var.database_name}-readrer-group"
  security_enabled = true
  members          = var.database_readers != [] ? data.azuread_groups.groups_readers[0].object_ids : []
}

resource "azuread_group" "database_contributor" {
  display_name     = "${var.database_name}-contributor-group"
  security_enabled = true
  members          = var.database_contributors != [] ? data.azuread_groups.groups_contributors[0].object_ids : []
}