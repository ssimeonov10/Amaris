variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual machine"
  type        = string
}

variable "location" {
  description = "The location/region where the virtual machine is created"
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B1s"  # Free tier eligible size
}

variable "subnet_id" {
  description = "The ID of the subnet where the VM should be connected"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "The SSH public key content for authentication"
  type        = string
  sensitive   = true
}

variable "os_disk_type" {
  description = "The type of the OS disk"
  type        = string
  default     = "Standard_LRS"  # Free tier eligible storage
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB"
  type        = number
  default     = 30
}

variable "os_image" {
  description = "The OS image reference for the virtual machine"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "network_interface_name" {
  description = "The name of the network interface"
  type        = string
  default     = null
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
  default     = null
}

variable "enable_public_ip" {
  description = "Whether to create a public IP for the virtual machine"
  type        = bool
  default     = false
}

variable "boot_diagnostics_storage_account_uri" {
  description = "The URI of the storage account for boot diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}