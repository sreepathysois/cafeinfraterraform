provider "azurerm" {
  features {}
}

# Existing Resource Group (VM will be created here)
resource "azurerm_resource_group" "rg" {
  name     = "myrg"
  location = "South India"
}

# EXISTING VNET
data "azurerm_virtual_network" "vnet" {
  name                = "cafevnet"
  resource_group_name = "my-network-rg"
}

# EXISTING SUBNET
data "azurerm_subnet" "subnet" {
  name                 = "public-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = "my-network-rg"
}

# NIC
resource "azurerm_network_interface" "nic" {
  name                = "dev-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "dev-ubuntu-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"

  admin_username                  = "azureuser"
  admin_password                  = "Msois@123"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
