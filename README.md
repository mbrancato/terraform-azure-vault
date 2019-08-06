# Vault Azure App Service Module

This is a Terraform module to deploy a [Vault](https://www.vaultproject.io/)
instance on
[Azure Web App for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/)
service. Vault is an open-source secrets management tool that generally is run
in a high-availability (HA) cluster. This implementation is a single instance
with auto-unseal and no HA support. Azure Web App for Containers is a way easily run a container on Azure without an orchestrator. This module makes use of the
following Azure resources:

* Azure App Service
* Azure Storage
* Azure Key Vault

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
  source              = "github.com/mbrancato/terraform-azure-vault"
  name                = "vault"
  resource_group_name = "${azurerm_resource_group.vault.name}"
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

## Security Concerns

The following things may be of concern from a security perspective:

* This is a publicly accessible Vault instance. Anyone with the DNS name can connect to it.
* The Terraform state will contain secrets. You may consider deleting it.
* App Service environment variables will contain secrets including credentials to read the unseal key.
* By default, Vault is running on a shared compute instance for the App Service plan.
