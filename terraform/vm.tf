resource "proxmox_vm_qemu" "k3s-servers" {
  count = var.server_count

  name        = "k3s-server${count.index + 1}"
  desc        = "k3s Server ${count.index + 1}"
  vmid        = parseint("10${count.index}", 10)
  target_node = "pve"

  onboot = true

  clone = "ubuntu-server-jammy-k3s"

  agent = 1 # Need this

  cpu     = "host"
  cores   = 4
  sockets = 1

  memory = 12288

  network {
    bridge = "vmbr0"
    model  = "virtio"
    tag    = var.vlan
  }

  os_type = "cloud-init"

  ipconfig0 = "gw=${var.network}1,ip=${var.network}1${count.index}/32"

  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF

  lifecycle {
    ignore_changes = [desc, tags, network, disk, cicustom, qemu_os]
  }
}
