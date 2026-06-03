# Root outputs — surface the pieces downstream modules and operators need.

output "resource_group_name" {
  description = "Name of the resource group holding the DTL stack."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region the stack is deployed to."
  value       = var.location
}

output "vnet_id" {
  description = "ID of the DTL virtual network."
  value       = module.networking.vnet_id
}

output "subnet_app_id" {
  description = "ID of the private application subnet (DTL VM)."
  value       = module.networking.subnet_app_id
}

output "subnet_gateway_id" {
  description = "ID of the Application Gateway subnet."
  value       = module.networking.subnet_gateway_id
}

output "subnet_data_id" {
  description = "ID of the private data subnet (PostgreSQL / private endpoints)."
  value       = module.networking.subnet_data_id
}
