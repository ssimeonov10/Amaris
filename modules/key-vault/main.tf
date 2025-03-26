resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  sku_name                    = var.sku_name
  tags                        = var.tags

  dynamic "access_policy" {
    for_each = var.owner_object_id != null ? [1] : []
    
    content {
      tenant_id = var.tenant_id
      object_id = var.owner_object_id

      key_permissions = var.owner_key_permissions
      secret_permissions = var.owner_secret_permissions
      certificate_permissions = var.owner_certificate_permissions
    }
  }

  dynamic "access_policy" {
    for_each = var.access_policies

    content {
      tenant_id = var.tenant_id
      object_id = access_policy.value.object_id
      
      key_permissions = access_policy.value.key_permissions
      secret_permissions = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
    }
  }

  dynamic "network_acls" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = lookup(network_acls.value, "ip_rules", [])
      virtual_network_subnet_ids = lookup(network_acls.value, "virtual_network_subnet_ids", [])
    }
  }
}

# Add secrets if provided
resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.kv.id
  
  # Most secrets should have content type set to distinguish them
  content_type = "secret"
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  count        = var.ssh_public_key != null ? 1 : 0
  name         = "SshPublicKey"
  value        = var.ssh_public_key
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "ssh-public-key"
}


resource "azurerm_key_vault_secret" "example_secret" {
  count        = var.example_secret != null ? 1 : 0
  name         = "ExampleSecret"
  value        = var.example_secret
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
}

resource "azurerm_key_vault_secret" "connection_string" {
  count        = var.connection_string != null ? 1 : 0
  name         = "ConnectionString"
  value        = var.connection_string
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "connection-string"
}