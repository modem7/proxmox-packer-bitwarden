# Ubuntu Server jammy
# ---
# Packer Template to create an Ubuntu Server (jammy) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
    sshkey = {
      version = ">= 1.0.7"
      source = "github.com/ivoronin/sshkey"
    }
  }
}

# Variable Definitions
// variable "proxmox_api_url" {
//     type = string
//     sensitive = true
// }

variable "proxmox_api_url" {
  type    = string
  sensitive = true
  default = "${env("PROX_API_URL")}"
  validation {
    condition     = length(var.proxmox_api_url) > 0
    error_message = <<EOF
The PROX_API_URL environment variable must be set.
EOF
  }
}

// variable "proxmox_api_token_id" {
//     type = string
//     sensitive = true
// }

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

// variable "proxmox_api_token_secret" {
//     type = string
//     sensitive = true
// }

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

data "sshkey" "install" {
  name = "packer"
  type = "ed25519"
}

# Resource definitions for the VM Template
source "proxmox" "ubuntu-server-jammy" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "proxmox" # add your proxmox node
#    vm_id = "100"
    vm_name = "ubuntu-server-jammy-packer"
    template_description = "Ubuntu Server Jammy Image"

    # VM OS ISO Settings
    # (Option 1) Local ISO File - Download Ubuntu ISO and Upload To Proxmox Server
    iso_file = "Proxmox:iso/ubuntu-22.04.1-live-server-amd64.iso"
    # - or -
    # (Option 2) Download ISO
    #iso_url = "https://releases.ubuntu.com/20.04/ubuntu-20.04.5-live-server-amd64.iso"
    #iso_checksum = "5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
    iso_storage_pool = "Proxmox"
    unmount_iso = true

    # VM OS Settings
    os = "l26"

    # VM System Settings
    qemu_agent = true

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "Proxmox"

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-single"

    disks {
        disk_size = "15G"
        format = "qcow2"
        storage_pool = "Proxmox"
        storage_pool_type = "directory"
        type = "scsi"
        cache_mode = "writethrough"
        io_thread = true
    }

    # VM CPU Settings
    cores = "2"
    cpu_type = "host"
    machine = "q35"
#    https://github.com/hashicorp/packer-plugin-proxmox/pull/90 and https://github.com/hashicorp/packer-plugin-proxmox/pull/93/files#diff-3cb137113817aa6a0421e15ce1ffe3fc66365d1ea99dd19237e50c578e7c8751
#    bios = "ovmf"
#    efidisk = "Proxmox"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr1"
        firewall = "false"
        vlan_tag = "50"
        packet_queues = "2"
    }

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    #http_directory = "http"
    http_content = {
      "/meta-data" = file("http/meta-data")
      "/user-data" = templatefile("http/user-data.pkrtpl.hcl", { ssh_key = data.sshkey.install.public_key })
    }
    # (Optional) Bind IP Address and Port
    http_bind_address = "192.168.50.100"
    http_port_min = 8802
    http_port_max = 8802

    # (Option 1) Add your Password here
    # ssh_password = "Xm2Y6vZVcViPnhFm"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    # ssh_clear_authorized_keys = true
    ssh_username = "packer"
    ssh_private_key_file = "${data.sshkey.install.private_key_path}"
    ssh_clear_authorized_keys = true

    # Raise the timeout, when installation takes longer
    ssh_timeout = "30m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-jammy"
    sources = ["source.proxmox.ubuntu-server-jammy"]

    # Transfer config files to template
    provisioner "file" {
        source = "files/configs"
        destination = "/tmp/configs/"
    }

    # Copying configs across
    provisioner "shell" {
        inline = [
            "sudo cp /tmp/configs/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
            "sudo cp /tmp/configs/00proxy /etc/apt/apt.conf.d/00proxy"
        ]
    }

    # Creating Swap
    provisioner "shell" {
        inline = [
            "sudo fallocate -l 2G /swapfile",
            "sudo chmod 600 /swapfile",
            "sudo mkswap /swapfile",
            "sudo swapon /swapfile",
            "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab"
        ]
    }

    # Removing Snap
    provisioner "shell" {
        inline = [
            "sudo rm -rf /var/cache/snapd",
            "sudo apt autoremove -y --purge snapd gnome-software-plugin-snap",
            "sudo rm -rf ~/snap",
            "sudo apt-mark hold snapd",
            "sudo systemctl daemon-reload"
        ]
    }

    # Deleting tmp directories
    provisioner "shell" {
        inline = [
            "sudo rm -rf /tmp/*",
            "sudo rm -rf /var/tmp/*"
        ]
    }

    # Enabling FSTrim + changing Tuned profile
    provisioner "shell" {
        inline = [
            "sudo fstrim -av",
            "sudo systemctl enable --now tuned",
            "sudo tuned-adm profile virtual-guest",
            "sudo systemctl enable fstrim.timer"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox. Needs to be last.
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo sync",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Add additional provisioning scripts here
    # ...
}
