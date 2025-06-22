resource "azurerm_storage_account" "storage_account" {
  name                          = "stgzrpw${var.environment}${var.location_abbreviation}001"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  access_tier                   = "Hot"
  https_traffic_only_enabled    = false
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  public_network_access_enabled = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.allowed_public_ip_addresses
    virtual_network_subnet_ids = var.allowed_virtual_network_subnet_ids
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "backups" {
  name                  = "backups"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}
