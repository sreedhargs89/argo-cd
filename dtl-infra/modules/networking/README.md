# Networking module

Builds the DTL virtual network and its security boundary. This is the
**reference module** — copy its layout (`main.tf` / `variables.tf` /
`outputs.tf` / `README.md`) when building the remaining Phase-2 modules.

## What it creates

| Resource | Purpose |
|----------|---------|
| `azurerm_virtual_network` | The DTL VNet |
| `azurerm_subnet.app` | Private subnet for the DTL VM — **no public IP** |
| `azurerm_subnet.gateway` | Dedicated subnet for Application Gateway (Azure requires its own) |
| `azurerm_subnet.data` | Private subnet, delegated to PostgreSQL Flexible Server |
| `azurerm_network_security_group.*` | Per-subnet NSGs enforcing the inbound model |

## Security posture

- The **only** allowed inbound path is `App Gateway subnet ← HTTPS(443) ← approved VPN/AGH CIDRs`.
  Until `allowed_vpn_source_cidrs` is set, the HTTPS rule is created as **Deny**
  (fail-closed) — set it per environment to open access.
- The **app** subnet only accepts traffic from the gateway subnet; everything
  else is denied.
- The **data** subnet only accepts PostgreSQL (5432) from the app subnet.

## Inputs

See `variables.tf`. Key ones: `vnet_address_space`, `subnet_*_prefix`,
`allowed_vpn_source_cidrs`.

## Outputs

`vnet_id`, `vnet_name`, `subnet_app_id`, `subnet_gateway_id`, `subnet_data_id`.
