# Vault Azure App Service Module

This is a Terraform module to deploy a [Vault](https://www.vaultproject.io/)
instance on [Azure Web App for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/)
service. Vault is an open-source secrets management tool that generally is run
in a high-availability (HA) cluster. This implementation is a single instance
with auto-unseal and no HA support. Azure Web App for Containers is a way 
easily run a container on Azure without an orchestrator. This module makes use 
of the following Azure resources:

* Azure App Service
* Azure Storage
* Azure Key Vault

---
## Table of Contents

- [Getting Started](#getting-started)
- [Variables](#variables)
  - [`name`](#name)
  - [`location`](#location)
  - [`resource_group_name`](#project)
  - [`vault_image`](#vault_image-optional)
  - [`vault_ui`](#vault_ui-optional)
  - [`vault_api_addr`](#vault_api_addr-optional)
  - [`vault_key_vault_tier`](#vault_key_vault_tier-optional)
  - [`vault_key_name`](#vault_key_name-optional)
  - [`vault_key_type`](#vault_key_type-optional)
  - [`vault_key_size`](#vault_key_size-optional)
  - [`vault_service_plan_tier`](#vault_service_plan_tier-optional)
  - [`vault_service_plan_size`](#vault_service_plan_size-optional)
  - [`vault_continuous_deployment`](#vault_continuous_deployment-optional)
  - [`vault_storage_account_kind`](#vault_storage_account_kind-optional)
  - [`vault_storage_account_tier`](#vault_storage_account_tier-optional)
  - [`vault_storage_account_replication`](#vault_storage_account_replication-optional)
- [Security Concerns](#security-concerns)
  
## Getting Started

To get started, you'll need a resource group to deploy the resources. Due to
various enterprise implementations of Azure access control, this module does
not create its own resource group. A basic implementation would look like the
following:

```hcl
provider "azurerm" {}

resource "azurerm_resource_group" "vault" {
  name     = "vault-rg"
  location = "eastus"
}

module "vault" {
  source              = "mbrancato/vault/azure"
  name                = "vault"
  resource_group_name = azurerm_resource_group.vault.name
  location            = "eastus"
}

output "vault_addr" {
  value = "${module.vault.vault_addr}"
}

```

After creating the resources, the Vault instance may be initialized.

Set the `VAULT_ADDR` environment variable.

```
$ export VAULT_ADDR=https://vault-8c48a910-as.azurewebsites.net
```

Ensure the vault is operational (might take a minute or two), uninitialized and
sealed.

```
$ vault status
Key                      Value
---                      -----
Recovery Seal Type       azurekeyvault
Initialized              false
Sealed                   true
Total Recovery Shares    0
Threshold                0
Unseal Progress          0/0
Unseal Nonce             n/a
Version                  n/a
HA Enabled               false
```

Initialize the vault.

```
$ vault operator init
Recovery Key 1: ...
Recovery Key 2: ...
Recovery Key 3: ...
Recovery Key 4: ...
Recovery Key 5: ...

Initial Root Token: s....

Success! Vault is initialized

Recovery key initialized with 5 key shares and a key threshold of 3. Please
securely distribute the key shares printed above.
```

From here, Vault is operational. Configure the auth methods needed and other
settings. The App Service may scale the container to zero, but the server
configuration and unseal keys are configured. When restarting, the Vault should
unseal itself automatically using the Azure Key Vault. For more information on
deploying Vault, read
[Deploy Vault](https://learn.hashicorp.com/vault/getting-started/deploy).

## Variables

### `name`
- Application name.

### `location`
- Azure location where resources are to be created.

### `resource_group_name`
- Azure resource group where resources are to be created.

### `vault_image` (optional)
- Vault container image.
  - See the [official docker image](https://hub.docker.com/_/vault).
  - default - `"vault:1.6.1""`

### `vault_ui` (optional)
- Enable Vault UI.
  - default - `false`

### `vault_api_addr` (optional)
- Full HTTP endpoint of Vault Server if using a custom domain name. Leave blank otherwise.
  - default - `""`

### `vault_key_vault_tier` (optional)
- Azure KeyVault service tier (Standard or Premium).
  - default - `"Standard"`

### `vault_key_name` (optional)
- Azure KeyVault key name.
  - default - `"vault-key"`

### `vault_key_type` (optional)
- Azure KeyVault cryptographic key type.
  - Specify the [key type](https://docs.microsoft.com/en-us/azure/key-vault/keys/about-keys#key-types-and-protection-methods).
  - default - `"RSA"`

### `vault_key_size` (optional)
- Azure KeyVault cryptographic key size.
  - default - `2048`

### `vault_service_plan_tier` (optional)
- Azure App Service Plan tier.
  -default - `"Free"`

### `vault_service_plan_size` (optional)
- Azure App Service Plan size.
  -default - `"F1"`

### `vault_continuous_deployment` (optional)
- Enable continuous deployment of new container tags (e.g. latest).
  - default - `false`

### `vault_storage_account_kind` (optional)
- Azure Service Account kind.
  - default - `"Storage"`

### `vault_storage_account_tier` (optional)
- Azure Service Account tier.
  -default - `"Free"`

### `vault_storage_account_replication` (optional)
- Azure Service Account replication type.
  -default - `"LRS"`

## Security Concerns

The following things may be of concern from a security perspective:

* This is a publicly accessible Vault instance. Anyone with the DNS name can connect to it. If you are interested in private endpoint support, open an issue.
* App Service environment variables will contain secrets including credentials to read the unseal key. Once managed service identities are supported fully by Vault on App Service, this should go away.
* By default, Vault is running on a shared compute instance for the App Service plan.
