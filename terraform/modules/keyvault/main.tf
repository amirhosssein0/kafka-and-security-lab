resource "azurerm_key_vault" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  enable_rbac_authorization  = var.enable_rbac_authorization
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
  tags                       = var.tags

  network_acls {
    bypass                     = "AzureServices"
    default_action             = length(var.allowed_ip_ranges) > 0 || var.aks_subnet_id != null ? "Deny" : "Allow"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.aks_subnet_id != null ? [var.aks_subnet_id] : []
  }
}

resource "azurerm_role_assignment" "secrets_reader" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.secrets_reader_principal_id
}