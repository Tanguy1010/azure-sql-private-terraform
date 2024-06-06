terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.62.0"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = ">= 0.3.0"
    }
  }
}