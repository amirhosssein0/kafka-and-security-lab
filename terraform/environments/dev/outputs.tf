output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "key_vault_uri" {
  value = module.keyvault.key_vault_uri
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}

output "velero_storage_account_name" {
  value = module.velero_storage.storage_account_name
}

output "velero_storage_account_key" {
  value     = module.velero_storage.storage_account_key
  sensitive = true
}