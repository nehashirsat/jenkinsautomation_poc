provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.prefix}-resources"
  location = var.location
}