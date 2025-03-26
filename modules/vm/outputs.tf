output "vm_id" {
  description = "The ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "private_ip_address" {
  description = "The private IP address of the virtual machine"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine (if enabled)"
  value       = var.enable_public_ip ? azurerm_public_ip.vm_pip[0].ip_address : null
}

output "principal_id" {
  description = "The principal ID of the system assigned identity"
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "nic_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.vm_nic.id
}

output "public_ip_id" {
  description = "The ID of the public IP (if enabled)"
  value       = var.enable_public_ip ? azurerm_public_ip.vm_pip[0].id : null
}