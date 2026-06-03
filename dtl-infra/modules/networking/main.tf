# Networking module for the DTL platform.
#
# Topology (mirrors the security model in the deep-dive §3 / §10):
#   - Virtual network with three subnets.
#   - "app"      : private subnet hosting the DTL VM. No public IP.
#   - "gateway"  : dedicated subnet for Azure Application Gateway (the only
#                  inbound entry point). Application Gateway REQUIRES its own
#                  subnet with nothing else in it.
#   - "data"     : private subnet for PostgreSQL Flexible Server delegation and
#                  private endpoints (Blob, Key Vault).
#
# Inbound to the gateway is restricted to the supplied VPN/AGH source CIDRs.
# The app subnet only accepts traffic from the gateway subnet.

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_app_prefix]
}

resource "azurerm_subnet" "gateway" {
  name                 = "snet-appgw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_gateway_prefix]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_data_prefix]

  # Delegation lets Azure Database for PostgreSQL Flexible Server inject into
  # this subnet for VNet integration.
  delegation {
    name = "postgresql-flexible-server"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# ---------------------------------------------------------------------------
# Network Security Groups
# ---------------------------------------------------------------------------

# Gateway NSG — allow HTTPS only from approved VPN/AGH sources, plus the
# Application Gateway management ports required by the platform.
resource "azurerm_network_security_group" "gateway" {
  name                = "nsg-appgw-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "allow-https-from-vpn"
    priority                   = 100
    direction                  = "Inbound"
    access                     = length(var.allowed_vpn_source_cidrs) > 0 ? "Allow" : "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = length(var.allowed_vpn_source_cidrs) > 0 ? var.allowed_vpn_source_cidrs : ["0.0.0.0/0"]
    destination_address_prefix = "*"
  }

  # Application Gateway v2 health/management traffic (required by Azure).
  security_rule {
    name                       = "allow-gateway-manager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-azure-lb"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

# App NSG — the VM only accepts traffic originating from the gateway subnet.
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "allow-from-gateway"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "8080"]
    source_address_prefix      = var.subnet_gateway_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-other-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Data NSG — only the app subnet may reach PostgreSQL (5432).
resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "allow-postgres-from-app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.subnet_app_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-other-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ---------------------------------------------------------------------------
# NSG <-> subnet associations
# (The gateway subnet keeps Azure-required rules; no Deny-all so platform
#  traffic is not blocked.)
# ---------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "gateway" {
  subnet_id                 = azurerm_subnet.gateway.id
  network_security_group_id = azurerm_network_security_group.gateway.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}
