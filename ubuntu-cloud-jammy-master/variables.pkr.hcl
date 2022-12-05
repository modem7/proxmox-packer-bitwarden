/*
    DESCRIPTION:
    Ubuntu Server 22.04 LTS variables using the Packer Builder for Proxmox (proxmox-iso).
*/

//  BLOCK: variable
//  Defines the input variables.

// Proxmox Credentials

// Proxmox API URL
variable "proxmox_api_url" {
  type    = string
  default = "${env("PROX_API_URL")}"
  validation {
    condition     = length(var.proxmox_api_url) > 0
    error_message = <<EOF
The PROX_API_URL environment variable must be set.
EOF
  }
}

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