terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.51.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = "root@pam"
  password = var.proxmox_password
  insecure = true
  ssh {
    agent    = true
    username = "root"
    password = var.proxmox_password
  }
}

resource "proxmox_virtual_environment_file" "talos-image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path      = "https://factory.talos.dev/image/c9078f9419961640c712a8bf2bb9174933dfcf1da383fd8ea2b7dc21493f8bac/v1.7.1/metal-amd64.iso"
    file_name = "talos-amd64.iso"
    checksum  = ""
  }
}

resource "proxmox_virtual_environment_vm" "fifi-steropes" {
  name        = "fifi-steropes"
  description = "Steropes K8S cluster"
  tags        = ["terraform", "k8s", "steropes", "cp"]
  node_name   = "pve"
  vm_id       = 667

  cpu {
    cores = 6
    type  = "host"
  }

  memory {
    dedicated = 16392
  }


  network_device {
    bridge      = "vmbr1"
    mac_address = "66:76:67:66:76:67"
  }

  scsi_hardware = "virtio-scsi-single"

  cdrom { # Talos ISO
    enabled   = "true"
    file_id   = proxmox_virtual_environment_file.talos-image.id
    interface = "ide0"
  }

  disk { # OS disk
    datastore_id = "local-lvm"
    interface    = "scsi0"
    file_format  = "raw"
    size         = 100
    iothread     = "true"
    ssd          = "true"
    cache        = "writeback"
    discard      = "on"
  }

  operating_system {
    type = "l26"
  }
}
