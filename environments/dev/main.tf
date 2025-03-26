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
        allow_ssh = {
          name                       = "allow-ssh"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    },
    {
      name           = "data-subnet"
      address_prefix = var.subnet_address_prefixes.data
      service_endpoints = ["Microsoft.Storage"]
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
  vm_size             = "Standard_B1s"
  admin_username      = "azureuser"
  ssh_public_key      = var.ssh_public_key
  enable_public_ip    = true
  os_disk_type        = "Standard_LRS"
  os_disk_size_gb     = 30
  
  os_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  tags = local.common_tags
}

# Key Vault Module (created after VM)
module "key_vault" {
  source              = "../../modules/key-vault"
  key_vault_name      = "${replace(local.resource_prefix, "-", "")}kv"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
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
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  
  ssh_public_key     = var.ssh_public_key
  example_secret     = "This-is-a-development-secret"
  connection_string  = "Server=dev-server;Database=testdb;User Id=dev;Password=devpass;"
  
  tags = local.common_tags
}