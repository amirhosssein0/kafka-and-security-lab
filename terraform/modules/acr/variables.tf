variable "name" {
  description = "Name of the container registry (globally unique, alphanumeric only)"
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

variable "sku" {
  description = "Throughput tier — better for frequent push/pull in CI"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Access via managed identity instead of username/password"
  type        = bool
  default     = false
}

variable "aks_kubelet_identity_object_id" {
  description = "Kubelet identity object ID from the aks module output"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the container registry"
  type        = map(string)
  default     = {}
}