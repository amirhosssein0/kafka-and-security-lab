terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatekafkalab13203"
    container_name       = "tfstate"
    key                  = "kafka-and-security-lab/dev.tfstate"
  }
}