# Provider configuration.
# Auth is supplied by the environment (az login / OIDC in CI / a service principal
# via ARM_* env vars) — never hardcode credentials here.
provider "azurerm" {
  features {
    key_vault {
      # Keep soft-deleted vaults recoverable; do not purge on destroy.
      purge_soft_delete_on_destroy = false
    }
  }

  # Set these via ARM_SUBSCRIPTION_ID / ARM_TENANT_ID env vars in CI,
  # or uncomment and drive from variables for local runs.
  # subscription_id = var.subscription_id
  # tenant_id       = var.tenant_id
}

provider "random" {}
