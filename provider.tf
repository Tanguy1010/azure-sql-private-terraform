provider "azurerm" {
  skip_provider_registration = "true"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = "768d3c30-cb1f-4c28-9f5e-acaf17c9f922"
}

provider "azapi" {
}

terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "=1.10.0"
    }
  }
}