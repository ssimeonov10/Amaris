resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan != null ? [var.ddos_protection_plan] : []
    
    content {
      id     = ddos_protection_plan.value.id
      enable = ddos_protection_plan.value.enable
    }
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
  
  service_endpoints    = lookup(each.value, "service_endpoints", null)
  
  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    
    content {
      name = delegation.value.name
      
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = lookup(delegation.value.service_delegation, "actions", null)
      }
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if lookup(subnet, "create_network_security_group", false) }

  name                = "${each.value.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if lookup(subnet, "create_network_security_group", false) }

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_network_security_rule" "rules" {
  for_each = {
    for rule in local.network_security_rules : "${rule.subnet_name}.${rule.name}" => rule
  }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  destination_port_range       = each.value.destination_port_range
  source_address_prefix        = each.value.source_address_prefix
  destination_address_prefix   = each.value.destination_address_prefix
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.nsg[each.value.subnet_name].name
}

locals {
  network_security_rules = flatten([
    for subnet_key, subnet in { for subnet in var.subnets : subnet.name => subnet if lookup(subnet, "create_network_security_group", false) } : [
      for rule_key, rule in lookup(subnet, "security_rules", {}) : {
        subnet_name               = subnet_key
        name                      = rule.name
        priority                  = rule.priority
        direction                 = rule.direction
        access                    = rule.access
        protocol                  = rule.protocol
        source_port_range         = lookup(rule, "source_port_range", "*")
        destination_port_range    = lookup(rule, "destination_port_range", "*")
        source_address_prefix     = lookup(rule, "source_address_prefix", "*")
        destination_address_prefix = lookup(rule, "destination_address_prefix", "*")
      }
    ]
  ])
}