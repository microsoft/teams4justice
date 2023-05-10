terraform {
  backend "azurerm" {
    resource_group_name  = "contoso-t4j-dev-rg"
    storage_account_name = "contosot4jdevsa"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}
