variable "proxmox_api_url" {
  type = string
}

variable "proxmox_token_id" {
  type = string
}

variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}

#variable "arch" {
#  type    = string
#  default = "amd64"
#}
#
#variable "vm_user" {
#  type = string
#}
#
#
#variable "cf_api_key" {
#  type      = string
#  sensitive = true
#}
#
#variable "traefik_password" {
#  type      = string
#  sensitive = true
#}
#
#variable "proxy_host_ip" {
#  type = string
#}
#
#variable "domain_name" {
#  type = string
#}
