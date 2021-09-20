resource "azurerm_linux_virtual_machine" "example" {
  name                = "${var.prefix}-machine"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.main.id]
  custom_data    = filebase64("azure_user_data.sh")
  
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("Azure_key.pub")
  } 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "linux_vm_public_ip" {
  name                = "${var.prefix}-linuxvm-public_ip"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
  sku = "Basic"
  tags = {
    environment = var.environment
  }
}