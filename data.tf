
data "azurerm_resource_group" "BioHRG" {
  name = var.resourceG
}

data "azurerm_subnet" "BioHsubnet" {
  name                 = var.subnet
  virtual_network_name = data.azurerm_virtual_network.BioHVnet.name
  resource_group_name  = data.azurerm_resource_group.BioHRG.name
}

data "azurerm_virtual_network" "BioHVnet" {
  name                = var.vnet
  resource_group_name = data.azurerm_resource_group.BioHRG.name
}