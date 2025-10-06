resource "azurerm_public_ip" "app-ip" {
    count                        = var.app_nodes
    name                         = "${var.owner}-${var.resource_name}-public-ip-app-${count.index}"
    location                     = var.virtual_network_location
    resource_group_name          = local.resource_group_name
    allocation_method            = "Static"
    zones                        = [element(local.app_zones, count.index)]
    sku                          = "Standard"
    tags                         = local.tags
}

resource "azurerm_network_interface" "app" {
    count                       = var.app_nodes
    name                        = "${var.owner}-${var.resource_name}-ni-app-${count.index}"
    location                    = var.virtual_network_location
    resource_group_name         = local.resource_group_name
    tags                        = local.tags

    ip_configuration {
    name                          = "network-interface-app-ip-${count.index}"
    subnet_id                     = azurerm_subnet.sn[count.index%3].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app-ip[count.index].id
    }
}


resource "azurerm_linux_virtual_machine" "app" {
    count                 = var.include_app == "yes" ? var.app_nodes : 0
    name                  = "${var.owner}-${var.resource_name}-vm-app-${count.index}"
    location              = var.virtual_network_location
    resource_group_name   = local.resource_group_name
    size                  = var.app_vm_size
    zone		  = local.app_zones[count.index%3]
    tags                  = local.tags

    network_interface_ids = [azurerm_network_interface.app[count.index].id]

    admin_username                  = var.login_username     # is this still required with an admin_ssh key block?
    disable_password_authentication = true
    admin_ssh_key {
        username                      = var.login_username    # a bug in the provider requires this to be adminuser
        public_key                    = data.azurerm_ssh_public_key.ssh_key.public_key
    }

    source_image_reference {
      publisher = var.test-publisher
      offer     = var.test-offer
      sku       = var.test-sku
      version   = var.test-version
    }

    os_disk {
        name      = "${var.owner}-${var.resource_name}-app-osdisk-${count.index}"
        caching   = "ReadWrite" # possible values: None, ReadOnly and ReadWrite
        storage_account_type = "Standard_LRS" # possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_SSD, StandardSSD_ZRS and Premium_ZRS
        disk_size_gb = var.app_disk_size
    }
    
}
