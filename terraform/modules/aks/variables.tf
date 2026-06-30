variable "name" {
  description = "Name of the AKS cluster"
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

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version; null lets Azure pick its default (will be wired to latest via data source in environments/dev)"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "Control plane pricing tier"
  type        = string
  default     = "Free"
}

variable "automatic_upgrade_channel" {
  description = "AKS automatic upgrade channel (patch, rapid, node-image, stable, or none)"
  type        = string
  default     = "none"
}

variable "outbound_type" {
  description = "Outbound routing type (explicit per Azure March 2026 policy)"
  type        = string
  default     = "loadBalancer"
}

variable "network_plugin" {
  description = "Azure CNI"
  type        = string
  default     = "azure"
}

variable "network_plugin_mode" {
  description = "Overlay mode — lower IP consumption from subnet"
  type        = string
  default     = "overlay"
}

variable "vnet_subnet_id" {
  description = "Subnet ID from vnet module output"
  type        = string
}

variable "node_vm_size" {
  description = "VM size for the system node pool (set in environments/dev)"
  type        = string
}

variable "auto_scaling_enabled" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum node count"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Maximum node count — caps cost"
  type        = number
  default     = 3
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB (minimum acceptable)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the AKS cluster"
  type        = map(string)
  default     = {}
}

variable "key_vault_secrets_provider_enabled" {
  description = "Enable the AKS Key Vault Secrets Provider (CSI driver) addon"
  type        = bool
  default     = true
}