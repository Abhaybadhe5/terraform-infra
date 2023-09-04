terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.71.0"
    }
  }
}

provider "azurerm" {
    features{}
  # Configuration options
}
resource "azurerm_resource_group" "firstrg" {
    name = "rg-tf-test-ci-001"
    location = "centralindia"
}
resource "azurerm_virtual_network" "firstrg" {
    name = "vnrt-tf-test-ci001"
    location = azurerm_resource_group.firstrg.location
    resource_group_name = azurerm_resource_group.firstrg.name
    address_space =["15.0.0.0/24"]
}
resource "azurerm_subnet" "firstrg" {
    name = "subnet-vnrt-tf-test-ci001"
    virtual_network_name = azurerm_virtual_network.firstrg.name
    resource_group_name = azurerm_resource_group.firstrg.name
    address_prefixes = ["15.0.0.0/25"]
  
}
resource "azurerm_public_ip" "firstrg" {
    name = "publicip001"
    resource_group_name = azurerm_resource_group.firstrg.name
    location = azurerm_resource_group.firstrg.location
    allocation_method = "Dynamic"
    idle_timeout_in_minutes = "4"
}
resource "azurerm_network_security_group" "firstrg" {
    name =  "vmdefnsg"
    location = azurerm_resource_group.firstrg.location
    resource_group_name = azurerm_resource_group.firstrg.name   
}
resource "azurerm_network_interface" "firstrg" {
    name = "nic-tf-test-ci001"
    location = azurerm_resource_group.firstrg.location
    resource_group_name = azurerm_resource_group.firstrg.name
    ip_configuration {
      name = "myipconfig"
      subnet_id = azurerm_subnet.firstrg.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.firstrg.id
    }  
}
resource "azurerm_windows_virtual_machine" "firstrg" {
 name = "vm-tf-test-ci01"
 location = azurerm_resource_group.firstrg.location
 resource_group_name = azurerm_resource_group.firstrg.name
 size = "Standard_B1ls"
 admin_username = "useradmin"
 admin_password = "Justdoit@2023"


 network_interface_ids = [
    azurerm_network_interface.firstrg.id
 ]
 os_disk {
   caching = "ReadWrite"
   storage_account_type = "Standard_LRS"
 }
 source_image_reference {
   offer = "WindowsServer"
   publisher = "MicrosoftWindowsServer"
   sku = "2019-DataCenter"
   version = "latest"
 }
}