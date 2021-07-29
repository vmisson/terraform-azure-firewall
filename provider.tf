# Configure the Azure Provider
provider "azurerm" {
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx"
  features {}
}

# Terraform backend config to use Storage Account. 
# You can comment this section if you want to use local state file. 
terraform {
  backend "azurerm" {
    resource_group_name  = "ManagementResourceGroup"
    storage_account_name = "MyStorageAccount"
    container_name       = "tfstate"
    key                  = "sandbox.tfstate"
  }
}