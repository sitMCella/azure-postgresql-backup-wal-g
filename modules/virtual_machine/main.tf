resource "azurerm_public_ip" "vm_public_ip" {
  name                = "ip-vm-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_network_interface" "network_interface" {
  name                = "nic-vm-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "id-vm-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                            = "vm-backup-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_B2as_v2"
  network_interface_ids           = [azurerm_network_interface.network_interface.id]
  admin_username                  = var.vm_admin_username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  os_disk {
    name                 = "disk-vm-${var.environment}-${var.location_abbreviation}-001"
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }
  custom_data = base64encode(file("${path.module}/init.sh"))
  tags        = var.tags
}

resource "azurerm_role_assignment" "application_storage_role_assignment" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

resource "azurerm_network_security_group" "network_security_group" {
  name                = "nsg-vm-${var.environment}-${var.location_abbreviation}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  security_rule {
    name                       = "allow_public_ip_address_ranges_1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_public_ip_addresses[0]
    destination_address_prefix = azurerm_public_ip.vm_public_ip.ip_address
  }
  security_rule {
    name                       = "allow_public_ip_address_ranges_2"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_public_ip_addresses[0]
    destination_address_prefix = var.virtual_machine_address_prefixes[0]
  }
  security_rule {
    name                       = "allow_postgresql_1"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_public_ip.vm_public_ip.ip_address
  }
  security_rule {
    name                       = "allow_postgresql_2"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = var.virtual_machine_address_prefixes[0]
  }
  security_rule {
    name                       = "allow_postgresql"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = azurerm_public_ip.vm_public_ip.ip_address
    destination_address_prefix = "*"
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "subnet_network_security_group_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}
