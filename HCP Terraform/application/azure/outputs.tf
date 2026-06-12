output "instance_public_ip" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_public_ip.web.ip_address
}
