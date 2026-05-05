provider "azurerm" {
  features {}
}

# -----------------------------
# USE EXISTING RESOURCE GROUP
# -----------------------------
data "azurerm_resource_group" "rg" {
  name = "myrg"
}

# -----------------------------
# PUBLIC IP
# -----------------------------
resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# -----------------------------
# NETWORK INTERFACE
# -----------------------------
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/7eaa1b0f-3d5a-444d-82c2-c0c3cb0f4da1/resourceGroups/my-network-rg/providers/Microsoft.Network/virtualNetworks/cafevnet/subnets/public-subnet"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# -----------------------------
# LINUX VIRTUAL MACHINE
# -----------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "dev-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_B1s"

  admin_username = "azureuser"
  admin_password = "Msois@123"

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
