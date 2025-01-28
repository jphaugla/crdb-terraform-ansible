# TODO:  CRDB instances greater than 3
locals {
  zones = ["1", "2", "3"]
}

locals {
  ip_list     = join(" ", azurerm_network_interface.crdb_network_interface[*].private_ip_address)
  join_string = (var.join_string != "" ? var.join_string : join(",", azurerm_network_interface.crdb_network_interface[*].private_ip_address))
  prometheus_string = (var.prometheus_string != "" ? var.prometheus_string : join(",", formatlist("%s:8080", azurerm_network_interface.crdb_network_interface[*].private_ip_address)))
}

data "azurerm_ssh_public_key" "ssh_key" {
  name                = var.ssh_key_name
  resource_group_name = var.ssh_key_resource_group
}

resource "azurerm_public_ip" "crdb-ip" {
  count                        = var.crdb_nodes
  name                         = "${var.owner}-${var.resource_name}-public-ip-${count.index}"
  location                     = var.virtual_network_location
  resource_group_name          = local.resource_group_name
  allocation_method            = "Static"
  zones                        = [element(local.zones, count.index)]
  sku                          = "Standard"
  tags                         = local.tags
}

resource "azurerm_network_interface" "crdb_network_interface" {
  count                     = var.crdb_nodes
  name                      = "${var.owner}-${var.resource_name}-ni-${count.index}"
  location                  = var.virtual_network_location
  resource_group_name       = local.resource_group_name
  tags                      = local.tags

  ip_configuration {
    name                          = "staticconfigured"
    subnet_id                     = azurerm_subnet.sn[count.index%3].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.crdb-ip[count.index].id
  }
}

resource "azurerm_managed_disk" "data_disk" {
  count                = var.create_ec2_instances == "yes" ? var.crdb_nodes : 0
  name                 = "${var.owner}-${var.resource_name}-storagedisk-${count.index}"
  location             = var.virtual_network_location
  zone                 = local.zones[count.index%3]
  resource_group_name  = local.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.crdb_store_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  count              = var.create_ec2_instances == "yes" ? var.crdb_nodes : 0
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.crdb-instance[count.index].id
  lun                = "1"
  caching            = "ReadWrite"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [managed_disk_id]
  }
}

resource "azurerm_linux_virtual_machine" "crdb-instance" {
  count                 = var.create_ec2_instances == "yes" ? var.crdb_nodes : 0
  name                  = "${var.owner}-${var.resource_name}-vm-crdb-${count.index}"
  location              = var.virtual_network_location
  resource_group_name   = local.resource_group_name
  size                  = var.crdb_vm_size
  tags                  = local.tags
  zone                  = local.zones[count.index%3]


  network_interface_ids = [azurerm_network_interface.crdb_network_interface[count.index].id]

  disable_password_authentication = true
  admin_username                  = var.login_username
  admin_ssh_key {
    username                      = var.login_username    # a bug in the provider requires this to be adminuser
    public_key                    = data.azurerm_ssh_public_key.ssh_key.public_key
  }

  source_image_reference {
    offer     = "RHEL"
    publisher = "RedHat"
    sku       = "9-lvm-gen2"
    version   = "latest"
  }

  os_disk {
    # do I assume this disk is deleted when the vm is deleted?  
    name      = "${var.owner}-${var.resource_name}-osdisk-${count.index}"
    caching   = "ReadWrite" # possible values: None, ReadOnly and ReadWrite
    storage_account_type = "Premium_LRS" # possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_SSD, StandardSSD_ZRS and Premium_ZRS
    disk_size_gb = var.crdb_disk_size
  }

}
