# Create network interface

resource "azurerm_network_interface" "BioHNic" {
  name                = "selfhostedagent-nic"
  location            = data.azurerm_resource_group.BioHRG.location
  resource_group_name = data.azurerm_resource_group.BioHRG.name

  ip_configuration {
    name                          = "selfhostedagentconfiguration"
    subnet_id                     = data.azurerm_subnet.BioHsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip.id
  }
}

# Create public IPs

resource "azurerm_public_ip" "pubip" {
  name                = "selfhostedagentpip"
  resource_group_name = data.azurerm_resource_group.BioHRG.name
  location            = data.azurerm_resource_group.BioHRG.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

# Create virtual machine

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "BioH-self-hosted-agent"
  resource_group_name = data.azurerm_resource_group.BioHRG.name
  location            = data.azurerm_resource_group.BioHRG.location
  size                = "Standard_B2ms"
  admin_username      = "selfhostedagent"
  network_interface_ids = [
    azurerm_network_interface.BioHNic.id,
  ]

  admin_ssh_key {
    username   = "selfhostedagent"
    public_key = file("./id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# Create virtual machine extension

resource "azurerm_virtual_machine_extension" "BioHHostname" {
  name                 = "BioH-Hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.linuxvm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "script": "${base64encode(file(var.script))}"
 }
SETTINGS
}
