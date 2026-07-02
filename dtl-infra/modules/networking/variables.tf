variable "name_prefix" {
  description = "Name prefix, e.g. dtl-phase2."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create network resources in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "subnet_app_prefix" {
  description = "CIDR for the private application subnet (DTL VM, no public IP)."
  type        = string
}

variable "subnet_gateway_prefix" {
  description = "CIDR for the dedicated Application Gateway subnet."
  type        = string
}

variable "subnet_data_prefix" {
  description = "CIDR for the private data subnet (PostgreSQL delegation / private endpoints)."
  type        = string
}

variable "allowed_vpn_source_cidrs" {
  description = "Source CIDRs (IBM VPN / AGH network) allowed to reach the App Gateway on 443."
  type        = list(string)
  default     = []
}
