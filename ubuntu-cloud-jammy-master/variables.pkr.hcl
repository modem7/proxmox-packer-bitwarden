/*
    DESCRIPTION:
    Ubuntu Server 22.04 LTS variables using the Packer Builder for Proxmox (proxmox-iso).
*/

//  BLOCK: variable
//  Defines the input variables.

// Bitwarden Variable definitions
// Proxmox Token ID
variable "proxmox_api_token_id" {
  type    = string
  sensitive = true
  default = "${env("PROX_API_ID")}"
  validation {
    condition     = length(var.proxmox_api_token_id) > 0
    error_message = <<EOF
The PROX_API_ID environment variable must be set.
EOF
  }
}

// Proxmox Token Secret
variable "proxmox_api_token_secret" {
  type    = string
  sensitive = true
  default = "${env("PROX_API_SECRET")}"
  validation {
    condition     = length(var.proxmox_api_token_secret) > 0
    error_message = <<EOF
The PROX_API_SECRET environment variable must be set.
EOF
  }
}

// Postfix
// Postfix Username
variable "postfix_user" {
  type    = string
  sensitive = true
  default = "${env("POSTFIX_USER")}"
  validation {
    condition     = length(var.postfix_user) > 0
    error_message = <<EOF
The PROX_API_SECRET environment variable must be set.
EOF
  }
}

// Postfix Pass
variable "postfix_pass" {
  type    = string
  sensitive = true
  default = "${env("POSTFIX_PASS")}"
  validation {
    condition     = length(var.postfix_pass) > 0
    error_message = <<EOF
The PROX_API_SECRET environment variable must be set.
EOF
  }
}

// Postfix Domain
variable "postfix_domain" {
  type    = string
  sensitive = true
  default = "${env("POSTFIX_DOMAIN")}"
  validation {
    condition     = length(var.postfix_domain) > 0
    error_message = <<EOF
The POSTFIX_DOMAIN environment variable must be set.
EOF
  }
}

// Postfix Relay
variable "postfix_relay" {
  type    = string
  sensitive = true
  default = "${env("POSTFIX_RELAY")}"
  validation {
    condition     = length(var.postfix_relay) > 0
    error_message = <<EOF
The POSTFIX_RELAY environment variable must be set.
EOF
  }
}

variable "proxmox_host" {}
variable "proxmox_port" {}
variable "build_username" {}
variable "build_password_encrypted" {}
variable "node" {}
variable "vm_name" {}
variable "iso_file" {}
variable "iso_storage_pool" {}
variable "insecure_skip_tls_verify" {
  type        = bool
  default     = true
}
variable "unmount_iso" {
  type        = bool
  default     = true
}
variable "vm_guest_os_language" {}
variable "vm_guest_os_keyboard" {}
variable "vm_guest_os_timezone" {}
variable "template_description" {}
variable "vm_os" {}
variable "vm_qemu_agent" {
  type        = bool
  default     = true
}
variable "vm_cloud_init" {
  type        = bool
  default     = true
}
variable "vm_cloud_init_storage_pool" {}
variable "vm_cloud_init_user" {}
variable "vm_cloud_init_pass" {}
variable "vm_cloud_init_ssh_key" {}
variable "vm_scsi_controller" {}
variable "vm_format" {}
variable "vm_id" {
  type        = string
  default     = null
}
variable "vm_storage_pool" {}
variable "vm_storage_pool_type" {}
variable "vm_type" {}
variable "vm_cache_mode" {}
variable "vm_io_thread" {
  type        = bool
  default     = true
}
variable "vm_packet_queues" {}
variable "vm_cores" {}
variable "vm_memory" {}
variable "vm_disk_size" {}
variable "vm_cpu_type" {}
variable "vm_machine" {}
variable "vm_model" {}
variable "vm_bridge" {}
variable "vm_firewall" {
  type        = bool
  default     = false
}
variable "vm_vlan_tag"  {}
variable "iso_path" {}
variable "vm_boot_wait" {}
variable "communicator_timeout" {}
variable "http_bind_address" {}
variable "http_port_min" {}
variable "http_port_max" {}
variable "ssh_username" {}
variable "ssh_clear_authorized_keys" {}

// Swap
variable "swap_size" {}