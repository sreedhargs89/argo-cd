# Phase-2 environment values.
# Apply with:  terraform apply -var-file=environments/phase2.tfvars

project     = "dtl"
environment = "phase2"
location    = "japaneast"

vnet_address_space    = ["10.20.0.0/16"]
subnet_app_prefix     = "10.20.1.0/24"
subnet_gateway_prefix = "10.20.2.0/24"
subnet_data_prefix    = "10.20.3.0/24"

# REQUIRED: replace with the real IBM VPN / AGH network ranges before applying.
# Left empty here so the gateway NSG fails closed (no inbound) by default.
allowed_vpn_source_cidrs = []

tags = {
  project    = "AGH-DTL"
  managed_by = "terraform"
  cost_owner = "IBM-Japan"
  phase      = "2"
}
