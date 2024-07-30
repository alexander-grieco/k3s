variable "proxmox_api_url" {
  type = string
}

variable "proxmox_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}

variable "server_count" {
  type    = number
  default = 3
}

variable "vlan" {
  type = number
}

variable "network" {
  type = string
}

variable "private_key_file" {
  type = string
}
