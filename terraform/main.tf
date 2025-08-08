resource "proxmox_virtual_environment_container" "test" {
  node_name    = var.proxmox_node
  description  = "Test Ubuntu LXC (24.04)"
  unprivileged = true
  started      = true

  initialization {
    hostname = "test-ubuntu"
    user_account { keys = [var.ssh_public_key] }
  }

  cpu { cores = 1 }

  memory {
    dedicated = 512
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features { nesting = false }

  operating_system {
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  }
}

output "test_container_id" {
  description = "Container ID"
  value       = proxmox_virtual_environment_container.test.id
}