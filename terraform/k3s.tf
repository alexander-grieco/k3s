data "local_sensitive_file" "private_key" {
  filename = pathexpand(var.private_key_file)
}

resource "random_bytes" "k3s_token" {
  length = 16
}

resource "remote_file" "k3s_primary" {
  depends_on = [
    proxmox_vm_qemu.k3s-servers,
  ]
  conn {
    host        = proxmox_vm_qemu.k3s-servers[0].ssh_host
    user        = "alex"
    private_key = data.local_sensitive_file.private_key.content
    sudo        = true
  }

  content = templatefile("${path.module}/k3s_files/primary-config.yaml.tftpl", {
    server_ip = proxmox_vm_qemu.k3s-servers[0].ssh_host
    token     = random_bytes.k3s_token.hex
  })
  path        = "/etc/rancher/k3s/config.yaml"
  permissions = "0644"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.k3s-servers[0].ssh_host
      user        = "alex"
      private_key = data.local_sensitive_file.private_key.content
      port        = "22"
    }
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' sh -s -",
    ]
  }
}


resource "remote_file" "k3s_server2" {
  depends_on = [
    proxmox_vm_qemu.k3s-servers,
  ]
  conn {
    host        = proxmox_vm_qemu.k3s-servers[1].ssh_host
    user        = "alex"
    private_key = data.local_sensitive_file.private_key.content
    sudo        = true
  }

  content = templatefile("${path.module}/k3s_files/config.yaml.tftpl", {
    server_ip = proxmox_vm_qemu.k3s-servers[1].ssh_host
    token     = random_bytes.k3s_token.hex
    server    = "https://${var.network}40:6443"
  })
  path        = "/etc/rancher/k3s/config.yaml"
  permissions = "0644"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.k3s-servers[1].ssh_host
      user        = "alex"
      private_key = data.local_sensitive_file.private_key.content
      port        = "22"
    }
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' sh -s -",
    ]
  }
}

resource "remote_file" "k3s_server3" {
  depends_on = [
    proxmox_vm_qemu.k3s-servers,
  ]
  conn {
    host        = proxmox_vm_qemu.k3s-servers[2].ssh_host
    user        = "alex"
    private_key = data.local_sensitive_file.private_key.content
    sudo        = true
  }

  content = templatefile("${path.module}/k3s_files/config.yaml.tftpl", {
    server_ip = proxmox_vm_qemu.k3s-servers[2].ssh_host
    token     = random_bytes.k3s_token.hex
    server    = "https://${var.network}40:6443"
  })
  path        = "/etc/rancher/k3s/config.yaml"
  permissions = "0644"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.k3s-servers[2].ssh_host
      user        = "alex"
      private_key = data.local_sensitive_file.private_key.content
      port        = "22"
    }
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' sh -s -",
    ]
  }
}
