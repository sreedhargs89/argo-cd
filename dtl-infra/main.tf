# Root module: creates the resource group and wires in child modules.
#
# Only the resource group and the networking module are active. The remaining
# modules from the Phase-2 requirements (§11 of the deep-dive) are stubbed out
# below with the exact wiring they will use, so the dev teams can fill in each
# module body and uncomment one block at a time.

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# ---------------------------------------------------------------------------
# Networking  —  FULLY BUILT reference module
# VNet, private app subnet (no public IP for the VM), dedicated App Gateway
# subnet, private data subnet, and NSGs.
# ---------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags

  vnet_address_space       = var.vnet_address_space
  subnet_app_prefix        = var.subnet_app_prefix
  subnet_gateway_prefix    = var.subnet_gateway_prefix
  subnet_data_prefix       = var.subnet_data_prefix
  allowed_vpn_source_cidrs = var.allowed_vpn_source_cidrs
}

# ---------------------------------------------------------------------------
# Remaining Phase-2 modules — STUBS. Build the module body, then uncomment.
# The wiring (inputs/outputs) shows how each consumes the networking module.
# ---------------------------------------------------------------------------

# module "key_vault" {
#   source              = "./modules/key_vault"
#   name_prefix         = local.name_prefix
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   tags                = local.tags
#   data_subnet_id      = module.networking.subnet_data_id
# }

# module "storage" {
#   # Blob: original / normalized / transformed files + logs (~12 GB), 7-yr lifecycle.
#   source              = "./modules/storage"
#   name_prefix         = local.name_prefix
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   tags                = local.tags
#   data_subnet_id      = module.networking.subnet_data_id
# }

# module "postgresql" {
#   # Azure Database for PostgreSQL — Flexible Server, VNet-integrated.
#   source                = "./modules/postgresql"
#   name_prefix           = local.name_prefix
#   resource_group_name   = azurerm_resource_group.this.name
#   location              = var.location
#   tags                  = local.tags
#   delegated_subnet_id   = module.networking.subnet_data_id
#   key_vault_id          = module.key_vault.id
# }

# module "compute" {
#   # Single Linux VM hosting Web + Validation + Transform services (no public IP).
#   source              = "./modules/compute"
#   name_prefix         = local.name_prefix
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   tags                = local.tags
#   app_subnet_id       = module.networking.subnet_app_id
# }

# module "app_gateway" {
#   # HTTPS termination + load balancing; cert sourced from Key Vault.
#   source                  = "./modules/app_gateway"
#   name_prefix             = local.name_prefix
#   resource_group_name     = azurerm_resource_group.this.name
#   location                = var.location
#   tags                    = local.tags
#   gateway_subnet_id       = module.networking.subnet_gateway_id
#   backend_private_ip      = module.compute.private_ip
#   key_vault_cert_secret_id = module.key_vault.tls_cert_secret_id
# }

# module "communication" {
#   # Azure Communication Services — outbound email notifications.
#   source              = "./modules/communication"
#   name_prefix         = local.name_prefix
#   resource_group_name = azurerm_resource_group.this.name
#   tags                = local.tags
# }

# module "monitoring" {
#   # Log Analytics workspace + diagnostic settings + alerts for Admins.
#   source              = "./modules/monitoring"
#   name_prefix         = local.name_prefix
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   tags                = local.tags
# }

# module "data_factory" {
#   # Azure Data Factory for structured ETL pipelines alongside the VM.
#   source              = "./modules/data_factory"
#   name_prefix         = local.name_prefix
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   tags                = local.tags
# }
