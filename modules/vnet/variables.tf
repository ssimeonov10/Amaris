variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network"
  type        = string
}

variable "location" {
  description = "The location/region where the virtual network is created"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "dns_servers" {
  description = "List of DNS servers to use for the virtual network"
  type        = list(string)
  default     = []
}

variable "ddos_protection_plan" {
  description = "DDoS protection plan configuration"
  type = object({
    id     = string
    enable = bool
  })
  default = null
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name                        = string
    address_prefix              = string
    service_endpoints           = optional(list(string))
    create_network_security_group = optional(bool, false)
    security_rules             = optional(map(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    })), {})
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}