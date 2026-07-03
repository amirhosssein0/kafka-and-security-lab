resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.dns_prefix
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = var.sku_tier
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled
  # automatic_upgrade_channel = var.automatic_upgrade_channel
  tags                      = var.tags

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                 = "default"
    vm_size              = var.node_vm_size
    vnet_subnet_id       = var.vnet_subnet_id
    os_disk_size_gb      = var.os_disk_size_gb
    auto_scaling_enabled = var.auto_scaling_enabled
    min_count            = var.min_count
    max_count            = var.max_count
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    outbound_type       = var.outbound_type
    network_policy       = var.network_policy

  }

  dynamic "key_vault_secrets_provider" {
  for_each = var.key_vault_secrets_provider_enabled ? [1] : []
  content {
    secret_rotation_enabled = true
  }
}
}