terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 1.35"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
