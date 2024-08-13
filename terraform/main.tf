terraform {
  required_version = "~>1.3"

  cloud {
    organization = "grieco-homelab"

    workspaces {
      name = "k3s-homelab"
    }
  }

  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      # version = "~> 2.9"
      version = "3.0.1-rc3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    #tls = {
    #  source  = "hashicorp/tls"
    #  version = "~> 4.0"
    #}
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret

  pm_tls_insecure = true
}

