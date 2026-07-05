variable "name" {
  description = "Name of the storage account (must be globally unique)"
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

variable "container_name" {
  description = "Name of the blob container for Velero backups"
  type        = string
  default     = "velero-backups"
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}