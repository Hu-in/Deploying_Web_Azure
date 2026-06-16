provider "azurerm" {
  features {}
}

variable "vm_count" {
  description = "Number of virtual machines to create (minimum 2, maximum 5)"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 2 && var.vm_count <= 5
    error_message = "vm_count must be between 2 and 5."
  }
}

resource "azurerm_lb_backend_address_pool" "bpool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backendPool"
}

data "azurerm_resource_group" "rg" {
  name = "Azuredevops"
}


resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "dev"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "my-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowVnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyInternet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowSSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    Environment = "dev"
  }
}
resource "azurerm_network_interface" "nic" {


  count = var.vm_count

  name = "my-nic-${count.index}"


  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment = "dev"
  }
}
resource "azurerm_linux_virtual_machine" "vm" {


  count = var.vm_count

  name = "my-vm-${count.index}"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    name                 = "my-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }



  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }


  tags = {
    Environment = "dev"
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "my-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"

  tags = {
    Environment = "dev"
  }
}
resource "azurerm_lb" "lb" {
  name                = "my-lb"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIP"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = {
    Environment = "dev"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "assoc" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpool.id
}