data "local_file" "private_key" {
  filename = pathexpand(var.private_key_file)
}

resource "random_bytes" "k3s_token" {
  length = 16
}

resource "proxmox_vm_qemu" "k3s-servers" {
  count = var.server_count

  name        = "k3s-server${count.index + 1}"
  desc        = "k3s Server ${count.index + 1}"
  vmid        = parseint("20${count.index}", 10)
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

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
      ide2 {
        cdrom {
          passthrough = false
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          backup    = true
          discard   = false
          format    = "raw"
          readonly  = false
          replicate = true
          size      = "128G"
          storage   = "local-lvm"
        }
      }
    }

  }

  scsihw = "virtio-scsi-pci"

  os_type = "cloud-init"

  ipconfig0 = "ip=${var.network}5${count.index}/16,gw=${var.network}1"
  # nameserver = "1.1.1.1"

  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF

  provisioner "remote-exec" {
    connection {
      host        = self.ssh_host
      user        = "alex"
      private_key = data.local_file.private_key.content
    }
    on_failure = continue

    inline = [<<-EOT

      if [ "${count.index}" -eq 0 ]; then
        echo "Setting up primary server"

        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' sh -s - \
          --cluster-init \
          --token "${random_bytes.k3s_token.hex}" \
          --write-kubeconfig-mode 644
      else
        sleep 30
        echo "Setting up server${count.index + 1}"
        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' sh -s - \
          --token "${random_bytes.k3s_token.hex}" \
          --server "https://${var.network}50:6443"
      fi
      EOT
    ]
  }

  lifecycle {
    ignore_changes = [desc, tags, network, cicustom, qemu_os]
  }
}

# Get kubconfig and store it locally
data "remote_file" "kubeconfig" {
  depends_on = [
    proxmox_vm_qemu.k3s-servers[0],
  ]

  conn {
    host        = proxmox_vm_qemu.k3s-servers[0].ssh_host
    user        = "alex"
    private_key = data.local_file.private_key.content
    port        = "22"
  }
  path = "/etc/rancher/k3s/k3s.yaml"
}

resource "local_file" "kubeconfig" {
  content         = replace(replace(data.remote_file.kubeconfig.content, "default", "k3s-homelab"), "127.0.0.1", proxmox_vm_qemu.k3s-servers[0].default_ipv4_address)
  filename        = pathexpand("~/.kube/k3s-config")
  file_permission = "0600"
}


