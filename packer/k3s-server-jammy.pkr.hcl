# Resource Definition for the VM Template
source "proxmox-iso" "k3s" {

  # Proxmox connection settings
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_token_id}"
  token                    = "${var.proxmox_token_secret}"
  insecure_skip_tls_verify = true

  #VM General Settings
  node                 = "proxmox"
  vm_id                = "899"
  vm_name              = "ubuntu-server-jammy-k3s"
  template_description = "Ubuntu Server 24.04 Image with Docker and k3s pre-installed"

  # VM OS Settings
  iso_file         = "local:iso/Ubuntu_Server_24.04.iso"
  iso_storage_pool = "local"
  unmount_iso      = true

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "128G"
    format       = "raw"
    storage_pool = "local-zfs"
    type         = "virtio"
  }

  # VM CPU Settings
  cores = "2"

  # VM Memory settings
  memory = "12288"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false" # default
  }

  # VM Cloud Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-zfs"

  # Packer Boot Commands
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  boot         = "c"
  boot_wait    = "10s"
  communicator = "ssh"

  # PACKER Autoinstall Settings
  http_directory = "http"

  ssh_username         = "root"
  ssh_private_key_file = "~/.ssh/github_ed25519"
  ssh_timeout          = "30m"
}

# Build Definition to create the VM Template.
build {

  name    = "k3s"
  sources = ["source.proxmox-iso.k3s"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  #provisioner "shell" {
  #  inline = [
  #    "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
  #    "rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
  #  ]
  #}

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      # "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/proxmox/396-pve.cfg"
    destination = "/tmp/396-pve.cfg"
  }

  provisioner "file" {
    source      = "files/k3s/bridge.conf"
    destination = "/etc/sysctl.d/bridge.conf"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["cp /tmp/396-pve.cfg /etc/cloud/cloud.cfg.d/396-pve.cfg"]
  }

  provisioner "shell" {
    inline = [
      "echo set debconf to Noninteractive",
    "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections"]
  }

  # Provisioning the VM Template with Docker Installation #4
  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL DOCKER'",
      "echo '=============================================='",
      "apt-get -y update",
      "apt-get install -y ca-certificates curl gnupg",
      "install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "chmod a+r /etc/apt/keyrings/docker.gpg",

      # Add the repository to Apt sources:
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get -y update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "usermod -aG docker alex",
    ]
  }

  # https://discuss.hashicorp.com/t/how-to-fix-debconf-unable-to-initialize-frontend-dialog-error/39201/2
  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'APT INSTALL PACKAGES & UPDATES'",
      "echo '=============================================='",
      "apt-get update",
      "apt-get -y install --no-install-recommends apt-utils git unzip wget",
      "apt-get -y upgrade",
      #"echo 'DIST UPGRADE'",
      #"apt-get -y dist-upgrade",
      "apt-get -y autoremove",

      #"echo 'Rebooting...'",
      #"reboot"
    ]
  }

  provisioner "shell" {
    inline = [
      "rm /etc/ssh/ssh_host_*",
      "truncate -s 0 /etc/machine-id",
      "apt -y autoremove --purge",
      "apt -y clean",
      "apt -y autoclean",
      "cloud-init clean",
      "sync"
    ]
  }
}

