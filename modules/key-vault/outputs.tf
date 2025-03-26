output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "ssh_public_key_id" {
  description = "The ID of the SSH public key secret"
  value       = length(azurerm_key_vault_secret.ssh_public_key) > 0 ? azurerm_key_vault_secret.ssh_public_key[0].id : null
  sensitive   = true
}

output "example_secret_id" {
  description = "The ID of the example secret"
  value       = length(azurerm_key_vault_secret.example_secret) > 0 ? azurerm_key_vault_secret.example_secret[0].id : null
  sensitive   = true
}

output "connection_string_id" {
  description = "The ID of the connection string secret"
  value       = length(azurerm_key_vault_secret.connection_string) > 0 ? azurerm_key_vault_secret.connection_string[0].id : null
  sensitive   = true
}