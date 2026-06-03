# Shared input variables consumed by the root module and passed down to children.

variable "project" {
  description = "Short project slug used in resource names."
  type        = string
  default     = "dtl"
}

variable "environment" {
  description = "Deployment environment slug (e.g. phase2, dev, prod)."
  type        = string
  default     = "phase2"
}

variable "location" {
  description = "Azure region for all resources. AGH workloads target Japan."
  type        = string
  default     = "japaneast"
}

variable "subscription_id" {
  description = "Target Azure subscription ID (AGH tenant). Usually set via ARM_SUBSCRIPTION_ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to every resource."
  type        = map(string)
  default = {
    project    = "AGH-DTL"
    managed_by = "terraform"
    cost_owner = "IBM-Japan"
  }
}

# ---------------------------------------------------------------------------
# Networking — consumed by modules/networking (the fully-built reference module)
# ---------------------------------------------------------------------------

variable "vnet_address_space" {
  description = "Address space for the DTL virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_app_prefix" {
  description = "CIDR for the private application subnet that hosts the DTL VM (no public IP)."
  type        = string
  default     = "10.20.1.0/24"
}

variable "subnet_gateway_prefix" {
  description = "CIDR for the Application Gateway subnet (must be a dedicated subnet)."
  type        = string
  default     = "10.20.2.0/24"
}

variable "subnet_data_prefix" {
  description = "CIDR for the private data subnet used by PostgreSQL / private endpoints."
  type        = string
  default     = "10.20.3.0/24"
}

variable "allowed_vpn_source_cidrs" {
  description = "Source CIDRs (IBM VPN / AGH network) permitted to reach the Application Gateway over HTTPS."
  type        = list(string)
  default     = [] # MUST be set per environment; empty means no inbound is allowed.
}
