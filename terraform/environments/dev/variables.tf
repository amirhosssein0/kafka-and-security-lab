variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "Japan East"
}

variable "node_vm_size" {
  description = "VM size for the AKS default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}
