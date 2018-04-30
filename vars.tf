# Generic variables

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  type        = "string"
  default     = ""
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  type        = "string"
  default     = "westus2"
}

# Storage account variables to store boot diagnostic

variable "sa_name" {
  description = "(Optional) Storage to use to store boot diagnostic. If not specify and boot diagnotic enable a SA will be created"
  type        = "string"
  default     = ""
}

variable "boot_diagnostics" {
  description = "(Optional) Enable or Disable boot diagnostics"
  type        = "string"
  default     = "false"
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics"
  type        = "string"
  default     = "Standard_LRS"
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type"
  type        = "string"
  default     = "Standard_LRS"
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Options are: Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = "string"
  default     = "Premium_LRS"
}

# Virtual machine variables

variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = "string"
  default     = ""
}

variable "is_windows_vm" {
  description = "Specify is the VM is windows."
  type        = "string"
  default     = false
}

variable "vm_hostname" {
  description = "Local name of the VM."
  type        = "string"
  default     = ""
}

variable "vm_os_image_id" {
  description = "ID of a custom iamge to deploy."
  type        = "string"
  default     = ""
}

variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  default     = ""
}

variable "vm_os_publisher" {
  description = "he name of the publisher of the image that you want to deploy."
  type        = "string"
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy."
  type        = "string"
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy."
  type        = "string"
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy."
  type        = "string"
  default     = "latest"
}

variable "vm_size" {
  description = "Size of the virtual machine."
  type        = "string"
  default     = ""
}

# VM config option
variable "provision_vm_agent_on_windows" {
  description = "(Optional) This value defaults to false."
  type = "string"
  default = true
}

variable "enable_automatic_upgrades_windows" {
  description = "(Optional) This value defaults to false."
  type = "string"
  default = false
}

variable "disable_password_authentication_on_linux" {
  description = "(Required) Specifies whether password authentication should be disabled. If set to false, an admin_password must be specified."
  type = "string"
  default = true
}

variable "public_ip" {
  description = "Set to 1 to assign any public IP addresses and 0 if you don't want to assign any public ip."
  type        = "string"
  default     = "1"
}

variable "public_ip_dns" {
  description = "DNS name associated with the public IP address."
  type        = "string"
  default     = ""
}

# Disk options
variable "delete_os_disk_on_termination" {
  description = "Set to true to delete OS disk on vm termination"
  type = "string"
  default = true
}

variable "delete_data_disk_on_termination" {
  description = "Set to true to delete data disk on vm termination"
  type = "string"
  default = false
}

# Data disk variables

variable "data_disk" {
  description = "Provision or not provision a data disk."
  type        = "string"
  default     = false
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = "string"
  default     = ""
}

# OS variables

variable "default_admin_user" {
  description = "Default admin user name."
  type        = "string"
  default     = ""
}

variable "default_admin_password" {
  description = "Default admin password."
  type        = "string"
  default     = "Pa$$w0rd2018"
}

# Default tags

variable "tags" {
  description = "Default tags to apply on the resource."
  type        = "map"

  default = {
    environment = ""
    terraform   = "true"
  }
}
