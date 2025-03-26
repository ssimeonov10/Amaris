variable "ssh_public_key" {
  description = "SSH public key to store in Key Vault"
  type        = string
  default     = null
  sensitive   = true
}

variable "example_secret" {
  description = "Example secret to store in Key Vault"
  type        = string
  default     = null
  sensitive   = true
}

variable "connection_string" {
  description = "Connection string to store in Key Vault"
  type        = string
  default     = null
  sensitive   = true
}
variable "resource_group_name" {
  description = "The name of the resource group in which to create the Key Vault"
  type        = string
}

variable "location" {
  description = "The location/region where the Key Vault is created"
  type        = string
}

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault"
  type        = string
  default     = "standard"
}

variable "enabled_for_disk_encryption" {
  description = "Whether Azure Disk Encryption is permitted to retrieve secrets from the vault"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Whether to enable purge protection"
  type        = bool
  default     = false
}

variable "owner_object_id" {
  description = "The object ID of the owner (user/service principal) who should have full access to the Key Vault"
  type        = string
  default     = null
}

variable "owner_key_permissions" {
  description = "Key permissions for the owner"
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update"]
}

variable "owner_secret_permissions" {
  description = "Secret permissions for the owner"
  type        = list(string)
  default     = ["Get", "List", "Set", "Delete"]
}

variable "owner_certificate_permissions" {
  description = "Certificate permissions for the owner"
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update"]
}

variable "access_policies" {
  description = "List of access policies for the Key Vault"
  type = list(object({
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "network_rules" {
  description = "Network rules for the Key Vault"
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "secrets" {
  description = "Map of secrets to add to the Key Vault"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}