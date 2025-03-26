output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.vnet.vnet_name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = module.vnet.vnet_address_space
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = module.vnet.subnet_ids
}

output "vm_id" {
  description = "The ID of the virtual machine"
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = module.vm.vm_name
}

output "vm_public_ip" {
  description = "The public IP address of the virtual machine"
  value       = module.vm.public_ip_address
}

output "vm_private_ip" {
  description = "The private IP address of the virtual machine"
  value       = module.vm.private_ip_address
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.key_vault.key_vault_uri
}

output "vm_identity_principal_id" {
  description = "The principal ID of the system assigned identity on the VM"
  value       = module.vm.principal_id
}