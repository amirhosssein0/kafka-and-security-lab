locals {
  tags = {
    project     = "kafka-and-security-lab"
    environment = "dev"
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}

module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-kafka-lab-dev"
  location = var.location
  tags     = local.tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-kafka-lab-dev"
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.10.0.0/16"]
  subnets = {
    aks = {
      address_prefixes = ["10.10.1.0/24"]
    }
  }
  tags = local.tags
}

module "aks" {
  source              = "../../modules/aks"
  name                = "aks-kafka-lab-dev"
  location            = var.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "kafkalabdev"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  vnet_subnet_id      = module.vnet.subnet_ids["aks"]
  node_vm_size        = var.node_vm_size
  tags                = local.tags
}

module "acr" {
  source                         = "../../modules/acr"
  name                           = "acrkafkalabdevamirhosssein0"
  location                       = var.location
  resource_group_name            = module.resource_group.name
  aks_kubelet_identity_object_id = module.aks.kubelet_identity_object_id
  tags                           = local.tags
}

module "keyvault" {
  source                      = "../../modules/keyvault"
  name                        = "kv-kafka-lab-dev"
  location                    = var.location
  resource_group_name         = module.resource_group.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  secrets_reader_principal_id = module.aks.key_vault_secrets_provider_object_id
  tags                        = local.tags
}