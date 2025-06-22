locals {
  tags = {
    environment = var.environment
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = "rg-${var.workload_name}-${var.environment}-${var.location_abbreviation}-001"
  location = var.location
}

module "virtual_network" {
  source = "./modules/network"

  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = var.location
  location_abbreviation = var.location_abbreviation
  environment           = var.environment
  tags                  = local.tags
}

module "storage_account" {
  source = "./modules/storage_account"

  resource_group_name                = azurerm_resource_group.resource_group.name
  location                           = var.location
  location_abbreviation              = var.location_abbreviation
  environment                        = var.environment
  allowed_public_ip_addresses        = var.allowed_public_ip_addresses
  allowed_virtual_network_subnet_ids = [module.virtual_network.subnet_virtual_machine_id]
  tags                               = local.tags
}

module "postgresql_database" {
  source = "./modules/postgresql"

  resource_group_name    = azurerm_resource_group.resource_group.name
  location               = var.location
  location_abbreviation  = var.location_abbreviation
  environment            = var.environment
  administrator_login    = var.postgresql_administrator_login
  administrator_password = var.postgresql_administrator_password
  tags                   = local.tags
}

module "virtual_machine" {
  source = "./modules/virtual_machine"

  resource_group_name              = azurerm_resource_group.resource_group.name
  location                         = var.location
  location_abbreviation            = var.location_abbreviation
  environment                      = var.environment
  subnet_id                        = module.virtual_network.subnet_virtual_machine_id
  vm_admin_username                = var.vm_admin_username
  vm_admin_password                = var.vm_admin_password
  storage_account_id               = module.storage_account.storage_account_id
  allowed_public_ip_addresses      = var.allowed_public_ip_addresses
  virtual_machine_address_prefixes = module.virtual_network.subnet_virtual_machine_address_prefixes
  tags                             = local.tags
}