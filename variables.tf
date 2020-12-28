variable "name" {
  description = "Application name."
  type        = string
}

variable "location" {
  description = "Azure location where resources are to be created."
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group where resources are to be created."
  type        = string
}

variable "vault_image" {
  description = "Vault container image to run."
  type        = string
  default     = "vault:1.6.1"
}

variable "vault_ui" {
  description = "Enable Vault UI."
  type        = bool
  default     = false
}

variable "vault_api_addr" {
  description = "Full HTTP endpoint of Vault Server if using a custom domain name. Leave blank otherwise."
  type        = string
  default     = ""
}

variable "vault_key_vault_tier" {
  description = "Azure KeyVault service tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "vault_key_name" {
  description = "Azure KeyVault key name."
  type        = string
  default     = "vault-key"
}

variable "vault_key_type" {
  description = "Azure KeyVault cryptographic key type."
  type        = string
  default     = "RSA"
}

variable "vault_key_size" {
  description = "Azure KeyVault cryptographic key size."
  type        = number
  default     = 2048
}

variable "vault_service_plan_tier" {
  description = "Azure App Service Plan tier (Free, Basic, Standard, PremiumV2)."
  type        = string
  default     = "Free"
}

variable "vault_service_plan_size" {
  description = "Azure App Service Plan size."
  type        = string
  default     = "F1"
}

variable "vault_continuous_deployment" {
  description = "Enable continuous deployment of new container tags (e.g. latest)."
  type        = bool
  default     = false
}

variable "vault_storage_account_kind" {
  description = "Azure Storage kind."
  type        = string
  default     = "Storage"
}

variable "vault_storage_account_tier" {
  description = "Azure Storage tier."
  type        = string
  default     = "Standard"
}

variable "vault_storage_account_replication" {
  description = "Azure Storage replication type."
  type        = string
  default     = "LRS"
}

