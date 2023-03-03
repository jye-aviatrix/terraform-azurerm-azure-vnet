# terraform-azurerm-azure-vnet

- This module deploy Azure vNet, subnet and route tables, you may seletive deploy test instance in the subnet.

## vNet_config parameter
Example configuration for your vNet
```
{
    name          = "test-vnet"
    address_space = ["10.0.0.0/24"]
    location      = "East US"
    subnets = {
      public1 = {
        address_prefixes              = ["10.0.0.0/26"]
        is_public_subnet              = true
        udr                           = true
        disable_bgp_route_propagation = true
        deploy_test_instance          = true
      }      
      private1 = {
        address_prefixes              = ["10.0.0.64/26"]
        is_public_subnet              = false
        udr                           = true
        disable_bgp_route_propagation = false
        deploy_test_instance          = true
      }
      private2 = {
        address_prefixes              = ["10.0.0.128/26"]
        is_public_subnet              = false
        deploy_test_instance          = false
      }
    }
}

name - Mandantory, name of the vNet
address_space - Mandantory, list type
location - location

In subnets section, start with unique subnet name
address_prefixes - Mandantory, list type
is_public_subnet - Mandantory, boolean, set to true and UDR will be programed with 0/0 point to internet.
udr - Optional, boolean default false. Set to true when you want to create UDR
disable_bgp_route_propagation - Optional, boolean default false. Set to true to disable Propagate Gateway Route in UDR
deploy_test_instance - Optional, boolean default false. Set to true to deploy a test VM in the subnet. If deployed in public subnet, you can SSH to it via your egress IP and it will also have default HTTP page.  Test VM is pingable from within RFC1918 range.

```

## providers.tf
In order to support count, for_each and depends_on parameters, when calling this module, I have removed local providers from the module.

You will have to declare providers in your code

```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
```