packer {
  required_plugins {
    azure = {
      version = ">= 1.4.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "example" {
  use_azure_cli_auth = true


  build_resource_group_name         = "Azuredevops"
  managed_image_resource_group_name = "Azuredevops"
  managed_image_name                = "myPackerImage"


  vm_size = "Standard_B1s"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "18.04-LTS"

  azure_tags = {
    Environment = "dev"
  }
}

build {
  sources = [
    "source.azure-arm.example"
  ]

  provisioner "shell" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo apt-get update",
      "sudo apt-get -y install nginx",
      "sudo systemctl enable nginx"
    ]
  }
}