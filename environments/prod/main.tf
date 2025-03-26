provider "azurerm" {
  features {}
}

locals {
  resource_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "Terraform"
    DeployDate  = formatdate("YYYY-MM-DD", timestamp())
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "${local.resource_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = "${local.resource_prefix}-vnet"
  address_space       = var.vnet_address_space
  
  subnets = [
    {
      name           = "app-subnet"
      address_prefix = var.subnet_address_prefixes.app
      create_network_security_group = true
      security_rules = {
        allow_http = {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        allow_https = {
          name                       = "allow-https"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        allow_ssh = {
          name                       = "allow-ssh"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*" 
          destination_port_range     = "22"
          source_address_prefix      = "REPLACE_IP_ADDRESS/32" # Needs to be replaced with the IP address of the machine you are connecting from
          destination_address_prefix = "*"
        }
      }
    },
    {
      name           = "data-subnet"
      address_prefix = var.subnet_address_prefixes.data
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
      create_network_security_group = true
      security_rules = {
        allow_internal = {
          name                       = "allow-internal"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*" 
          source_address_prefix      = var.subnet_address_prefixes.app
          destination_address_prefix = "*"
        }
      }
    },
    {
      name           = "bastion-subnet"
      address_prefix = var.subnet_address_prefixes.bastion
    }
  ]
  
  tags = local.common_tags
}


module "vm" {
  source              = "../../modules/vm"
  vm_name             = "${local.resource_prefix}-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.vnet.subnet_ids["app-subnet"]
  vm_size             = "Standard_B2s"
  admin_username      = "azureuser"
  ssh_public_key      = var.ssh_public_key
  enable_public_ip    = false 
  os_disk_type        = "Premium_LRS"
  os_disk_size_gb     = 64
  
  os_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  tags = local.common_tags
}

module "key_vault" {
  source              = "../../modules/key-vault"
  key_vault_name      = "${replace(local.resource_prefix, "-", "")}kv"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  purge_protection_enabled = true
  
  owner_object_id     = data.azurerm_client_config.current.object_id
  
  access_policies = [
    {
      object_id               = module.vm.principal_id
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = []
    }
  ]
  
  network_rules = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.vnet.subnet_ids["app-subnet"]]
  }
  

  ssh_public_key     = var.ssh_public_key
  example_secret     = "This-is-a-production-secret"
  connection_string  = "Server=prod-server;Database=proddb;User Id=prod;Password=prodpass;" 

  tags = local.common_tags
}