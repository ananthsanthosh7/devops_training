variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-stock-dashboard"
}

variable "vm_size" {
  description = "VM size for the Azure Linux VM."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key to use for the Linux VM."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  description = "Tags applied to Azure resources."
  type        = map(string)
  default = {
    environment = "dev"
    project     = "stock-dashboard"
    owner       = "personal"
  }
}
