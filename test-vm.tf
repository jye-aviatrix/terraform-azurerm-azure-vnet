module "azure-linux-vm-public" {
  source  = "jye-aviatrix/azure-linux-vm-public/azure"
  version = "3.0.1"
  for_each                      = { for k, v in var.vNet_config.subnets : k => v if v.is_public_subnet && try(v.deploy_test_instance,false) }
  public_key_file = var.public_key_file
  region = azurerm_virtual_network.this.location
  resource_group_name = azurerm_virtual_network.this.resource_group_name
  subnet_id = azurerm_subnet.this[each.key].id
  vm_name = "${var.vNet_config.name}-${each.key}"
}

module "azure-linux-vm-private" {
  source  = "jye-aviatrix/azure-linux-vm-private/azure"
  version = "3.0.1"
  for_each                      = { for k, v in var.vNet_config.subnets : k => v if !v.is_public_subnet && try(v.deploy_test_instance,false) }
  public_key_file = var.public_key_file
  region = azurerm_virtual_network.this.location
  resource_group_name = azurerm_virtual_network.this.resource_group_name
  subnet_id = azurerm_subnet.this[each.key].id
  vm_name = "${var.vNet_config.name}-${each.key}"
}

output "public_vm" {
  value = module.azure-linux-vm-public
}

output "private_vm" {
  value = module.azure-linux-vm-private
}