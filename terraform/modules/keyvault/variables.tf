variable "name" {
  description = "Vault name — alphanumeric/hyphens only, 3-24 chars, must start with a letter"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID, sourced from data.azurerm_client_config in environments/dev"
  type        = string
}

variable "sku_name" {
  description = "Vault SKU; premium is only needed for HSM-backed keys, not used here"
  type        = string
  default     = "standard"
}

variable "enable_rbac_authorization" {
  description = "Use RBAC instead of legacy access policies"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Allows clean destroy/recreate within a session"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention in days; minimum allowed value"
  type        = number
  default     = 7
}

variable "secrets_reader_principal_id" {
  description = "Principal ID granted Secrets User access, from the aks module output"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the key vault"
  type        = map(string)
  default     = {}
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges (CIDR) for Key Vault network ACL; empty = allow all"
  type        = list(string)
  default     = []
}

variable "aks_subnet_id" {
  description = "AKS subnet ID allowed through Key Vault network ACL"
  type        = string
  default     = null
}