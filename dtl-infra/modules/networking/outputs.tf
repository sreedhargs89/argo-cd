output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_app_id" {
  description = "ID of the private application subnet (DTL VM)."
  value       = azurerm_subnet.app.id
}

output "subnet_gateway_id" {
  description = "ID of the Application Gateway subnet."
  value       = azurerm_subnet.gateway.id
}

output "subnet_data_id" {
  description = "ID of the private data subnet (PostgreSQL / private endpoints)."
  value       = azurerm_subnet.data.id
}
