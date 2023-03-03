variable "resource_group_name" {
  description = "Provide existing resource group name"
  type        = string
}

variable "vNet_config" {
  description = "Provide vNet configuration object, disable_bgp_route_propagation default to false if not set"

  default = {
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
}

variable "ew_nva" {
  description = "Provide IP address of NVA(Firewall) that performs East/West inspection or the load baancer IP of E/W NVA"
  type = string
  default = "8.8.8.8"
}

variable "egress_nva" {
  description = "Provide IP address of NVA(Firewall) that performs Egress inspection or the load baancer IP of Egress NVA"
  type = string
  default = "4.4.4.4"
}

variable "public_key_file" {
  description = "Provide path to SSH public key for the VM"
  type = string
  default = ""
}