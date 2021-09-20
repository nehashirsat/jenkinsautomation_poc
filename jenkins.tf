/*resource "null_resource" "connection" {
  # ...
  depends_on = [azurerm_linux_virtual_machine.example]

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo su",
      "sh /tmp/script.sh",
    ]
  }
  connection {
    type     = "ssh"
    user     = "adminuser"
    private_key = file("Azure_key.pem")
    host     = azurerm_linux_virtual_machine.example.public_ip_address
  }

}

*/
