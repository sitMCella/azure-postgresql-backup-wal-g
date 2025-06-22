output "virtual_network_id" {
  description = "The Resource ID of the Azure Virtual Network."
  value       = azurerm_virtual_network.virtual_network.id
}

output "subnet_virtual_machine_id" {
  description = "The Resource ID of the Virtual Machine subnet."
  value       = azurerm_subnet.subnet_virtual_machine.id
}

output "subnet_virtual_machine_address_prefixes" {
  description = "The address prefixes of the Virtual Machine subnet."
  value       = azurerm_subnet.subnet_virtual_machine.address_prefixes
}
