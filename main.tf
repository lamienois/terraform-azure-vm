resource "random_id" "vm_random_id" {
  keepers = {
    vm_hostname = "${var.vm_hostname}"
  }

  byte_length = 1
}

locals {
  default_name = "${lower(var.vm_hostname)}${lower(random_id.vm_random_id.dec)}"
}

resource "azurerm_storage_account" "vm_boot_diag_sa" {
  count                    = "${var.boot_diagnostics == "true" && var.sa_name == "" ? 1 : 0}"
  name                     = "${local.default_name}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "${element(split("_", var.boot_diagnostics_sa_type),0)}"
  account_replication_type = "${element(split("_", var.boot_diagnostics_sa_type),1)}"

  tags = "${var.tags}"
}

resource "azurerm_public_ip" "vm_public_ip" {
  count                        = "${var.public_ip}"
  name                         = "${local.default_name}-pubip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "Static"

  tags = "${var.tags}"
}

resource "azurerm_network_interface" "vm_private_ip" {
  name                = "${local.default_name}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${local.default_name}-confip"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${var.vnet_subnet_id}"
    public_ip_address_id          = "${length(azurerm_public_ip.vm_public_ip.id) > 0 ? azurerm_public_ip.vm_public_ip.id : ""}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm_lunix" {
  count                 = "${(var.data_disk == "false") && (!contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer")) ? 1 : 0}"
  name                  = "${local.default_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.vm_private_ip.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    id        = "${var.vm_os_image_id}"
    publisher = "${var.vm_os_image_id == "" ? var.vm_os_publisher : ""}"
    offer     = "${var.vm_os_image_id == "" ? var.vm_os_offer : ""}"
    sku       = "${var.vm_os_image_id == "" ? var.vm_os_sku : ""}"
    version   = "${var.vm_os_image_id == "" ? var.vm_os_version : ""}"
  }

  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_os_disk {
    name              = "${local.default_name}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    admin_username = "${var.default_admin_user}"
    computer_name  = "${local.default_name}"
    admin_password = "${var.default_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.disable_password_authentication_on_linux}"

    #ssh_keys {
    # path = "/home/${var.default_admin_user}/.ssh/authorized_keys"
    # key_data = "${file("${var.ssh_key}")}"
    #}
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" && var.sa_name == "" ? join(",", azurerm_storage_account.vm_boot_diag_sa.*.primary_blob_endpoint) : "https://${var.sa_name}.blob.core.windows.net/"}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm_linux_with_data_disk" {
  count                 = "${(var.data_disk == "true") && (!contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer")) ? 1 : 0}"
  name                  = "${local.default_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.vm_private_ip.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    id        = "${var.vm_os_image_id}"
    publisher = "${var.vm_os_image_id == "" ? var.vm_os_publisher : ""}"
    offer     = "${var.vm_os_image_id == "" ? var.vm_os_offer : ""}"
    sku       = "${var.vm_os_image_id == "" ? var.vm_os_sku : ""}"
    version   = "${var.vm_os_image_id == "" ? var.vm_os_version : ""}"
  }

  delete_os_disk_on_termination    = "${var.delete_os_disk_on_termination}"
  delete_data_disks_on_termination = "${var.delete_data_disk_on_termination}"

  storage_os_disk {
    name              = "${local.default_name}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }

  storage_data_disk {
    name              = "${local.default_name}-datadisk"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "${var.data_disk_size_gb}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    admin_username = "${var.default_admin_user}"
    computer_name  = "${local.default_name}"
    admin_password = "${var.default_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.disable_password_authentication_on_linux}"

    #ssh_keys {
    # path = "/home/${var.default_admin_user}/.ssh/authorized_keys"
    # key_data = "${file("${var.ssh_key}")}"
    #}
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" && var.sa_name == "" ? join(",", azurerm_storage_account.vm_boot_diag_sa.*.primary_blob_endpoint) : "https://${var.sa_name}.blob.core.windows.net/"}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm_windows" {
  #count = "${1 - var.data_disk}"
  count                 = "${(var.is_windows_vm == "true") || contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer") && (var.data_disk == "false") ? 1 : 0}"
  name                  = "${local.default_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.vm_private_ip.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    id        = "${var.vm_os_image_id}"
    publisher = "${var.vm_os_image_id == "" ? var.vm_os_publisher : ""}"
    offer     = "${var.vm_os_image_id == "" ? var.vm_os_offer : ""}"
    sku       = "${var.vm_os_image_id == "" ? var.vm_os_sku : ""}"
    version   = "${var.vm_os_image_id == "" ? var.vm_os_version : ""}"
  }

  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_os_disk {
    name              = "${local.default_name}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    admin_username = "${var.default_admin_user}"
    computer_name  = "${local.default_name}"
    admin_password = "${var.default_admin_password}"
  }

  os_profile_windows_config {
    provision_vm_agent        = "${var.provision_vm_agent_on_windows}"
    enable_automatic_upgrades = "${var.enable_automatic_upgrades_windows}"
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" && var.sa_name == "" ? join(",", azurerm_storage_account.vm_boot_diag_sa.*.primary_blob_endpoint) : "https://${var.sa_name}.blob.core.windows.net/"}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm_windows_with_data_disk" {
  count                 = "${(var.is_windows_vm == "true") || contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer") && (var.data_disk == "true") ? 1 : 0}"
  name                  = "${local.default_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.vm_private_ip.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    id        = "${var.vm_os_image_id}"
    publisher = "${var.vm_os_image_id == "" ? var.vm_os_publisher : ""}"
    offer     = "${var.vm_os_image_id == "" ? var.vm_os_offer : ""}"
    sku       = "${var.vm_os_image_id == "" ? var.vm_os_sku : ""}"
    version   = "${var.vm_os_image_id == "" ? var.vm_os_version : ""}"
  }

  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"
  delete_data_disks_on_termination = "${var.delete_data_disk_on_termination}"

  storage_os_disk {
    name              = "${local.default_name}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }

  storage_data_disk {
    name              = "${local.default_name}-datadisk"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "${var.data_disk_size_gb}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    admin_username = "${var.default_admin_user}"
    computer_name  = "${local.default_name}"
    admin_password = "${var.default_admin_password}"
  }

  os_profile_windows_config {
    provision_vm_agent        = "${var.provision_vm_agent_on_windows}"
    enable_automatic_upgrades = "${var.enable_automatic_upgrades_windows}"
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" && var.sa_name == "" ? join(",", azurerm_storage_account.vm_boot_diag_sa.*.primary_blob_endpoint) : "https://${var.sa_name}.blob.core.windows.net/"}"
  }

  tags = "${var.tags}"
}
