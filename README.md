# Azure Virtual Network Terraform Module

This Terraform module deploys a Virtual Network (VNET) in Azure with associated subnets, network security groups, and security rules. It's designed to be flexible and reusable across different environments.

## Features

- Create an Azure Virtual Network with customizable address space
- Deploy multiple subnets with configurable address prefixes
- Configure Network Security Groups (NSGs) with security rules
- Associate NSGs with subnets
- Configure service endpoints for secure service connections
- Support subnet delegations for PaaS services
- Optional DDoS protection integration

## Prerequisites

- Terraform v1.0.0 or later
- Azure subscription
- Azure CLI or appropriate service principal credentials

## Usage

### Basic Example

```hcl
module "vnet" {
  source              = "path/to/modules/vnet"
  resource_group_name = "example-rg"
  location            = "eastus"
  vnet_name           = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name           = "web-subnet"
      address_prefix = "10.0.1.0/24"
    },
    {
      name           = "app-subnet"
      address_prefix = "10.0.2.0/24"
    }
  ]
  
  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

## Advanced Example with Security Groups and Rules

```hcl
module "vnet" {
  source              = "path/to/modules/vnet"
  resource_group_name = "example-rg"
  location            = "eastus"
  vnet_name           = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name                        = "web-subnet"
      address_prefix              = "10.0.1.0/24"
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
        },
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
        },
        allow_ssh = {
          name                       = "allow-ssh"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "x.x.x.x/32" # Replace with your IP
          destination_address_prefix = "*"
        }
      }
    },
    {
      name             = "data-subnet"
      address_prefix   = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
  ]
}

## Required Inputs

| Name                | Description                                     | Type         | Required |
|---------------------|-------------------------------------------------|--------------|----------|
| resource_group_name | Name of the resource group                      | string       | Yes      |
| location            | Azure region where resources will be created    | string       | Yes      |
| vnet_name           | Name of the virtual network                     | string       | Yes      |
| address_space       | List of address spaces for the VNET             | list(string) | Yes      |

## Optional Inputs

| Name                | Description                                      | Type         | Default | Required |
|---------------------|--------------------------------------------------|--------------|---------|----------|
| dns_servers         | List of DNS servers for the VNET                 | list(string) | []      | No       |
| ddos_protection_plan| DDoS protection plan configuration               | object       | null    | No       |
| subnets             | List of subnet configurations                    | list(object) | []      | No       |
| tags                | Tags to apply to all resources                   | map(string)  | {}      | No       |

## Subnet Configuration Options

The **subnets** variable accepts a list of objects with the following properties:

| Property                      | Description                                        | Type         | Default | Required |
|-------------------------------|----------------------------------------------------|--------------|---------|----------|
| name                          | Subnet name                                        | string       | n/a     | Yes      |
| address_prefix                | Subnet address prefix in CIDR notation             | string       | n/a     | Yes      |
| service_endpoints             | List of service endpoints                          | list(string) | null    | No       |
| create_network_security_group | Whether to create a network security group         | bool         | false   | No       |
| security_rules                | Map of security rules to create                    | map(object)  | {}      | No       |
| delegation                    | Subnet delegation for PaaS services                | object       | null    | No       |
