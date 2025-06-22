// Note: Manually assign the client public IP address to the PostgreSQL Flexible Server firewall.
// Note: Manually allow any Azure service in the PostgreSQL Flexible Server firewall.
resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                          = "psql-example-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "16"
  public_network_access_enabled = true
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  geo_redundant_backup_enabled  = false
  create_mode                   = "Default"
  zone                          = "1"
  storage_mb                    = 32768
  storage_tier                  = "P4"
  sku_name                      = "B_Standard_B1ms"
  tags                          = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "database1" {
  name      = "database1"
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}
