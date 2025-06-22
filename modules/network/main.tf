resource "azurerm_virtual_network" "virtual_network" {
  name                = "vnet-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/20"]
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet" "subnet_virtual_machine" {
  name                 = "snet-vm-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.1.0/27"]
  service_endpoints    = ["Microsoft.Storage"]
}
