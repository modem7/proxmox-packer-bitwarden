// Ubuntu Server jammy
// Packer Template to create an Ubuntu Server (jammy) on Proxmox

packer {
  required_version = ">= 1.8.4"
  required_plugins {
    proxmox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
    sshkey = {
      version = ">= 1.0.7"
      source = "github.com/ivoronin/sshkey"
    }
    // ansible = {
    //   version = ">= 1.0.2"
    //   source  = "github.com/hashicorp/ansible"
    // }
  }
}

data "sshkey" "packer" {}

// Resource definitions for the VM Template
source "proxmox" "ubuntu-server-jammy" {
 
    // Proxmox Connection Settings
    proxmox_url = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    // (Optional) Skip TLS Verification
    insecure_skip_tls_verify = "${var.insecure_skip_tls_verify}"
    
    // VM General Settings
    node = "${var.node}" // add your proxmox node
    vm_id = "${var.vm_id}"
    vm_name = "${var.vm_name}"
    template_description = "${var.template_description}"

    // VM OS ISO Settings
    // (Option 1) Local ISO File - Download Ubuntu ISO and Upload To Proxmox Server
    iso_file = "${var.iso_path}/${var.iso_file}"
    // - or -
    // (Option 2) Download ISO
    // iso_url = "https://releases.ubuntu.com/20.04/ubuntu-20.04.5-live-server-amd64.iso"
    // iso_checksum = "5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
    iso_storage_pool = "${var.iso_storage_pool}"
    unmount_iso = "${var.unmount_iso}"

    // VM OS Settings
    os = "${var.vm_os}"

    // VM System Settings
    qemu_agent = "${var.vm_qemu_agent}"

    // VM Cloud-Init Settings
    cloud_init = "${var.vm_cloud_init}"
    cloud_init_storage_pool = "${var.vm_cloud_init_storage_pool}"

    // VM Hard Disk Settings
    scsi_controller = "${var.vm_scsi_controller}"

    disks {
        disk_size = "${var.vm_disk_size}"
        format = "${var.vm_format}"
        storage_pool = "${var.vm_storage_pool}"
        storage_pool_type = "${var.vm_storage_pool_type}"
        type = "${var.vm_type}"
        cache_mode = "${var.vm_cache_mode}"
        io_thread = "${var.vm_io_thread}"
    }

    // VM CPU Settings
    cores = "${var.vm_cores}"
    cpu_type = "${var.vm_cpu_type}"
    machine = "${var.vm_machine}"
    // https://github.com/hashicorp/packer-plugin-proxmox/pull/90 and https://github.com/hashicorp/packer-plugin-proxmox/pull/93
    // bios = "ovmf"
    // efidisk = "Proxmox"
    
    // VM Memory Settings
    memory = "${var.vm_memory}" 

    // VM Network Settings
    network_adapters {
        model = "${var.vm_model}" 
        bridge = "${var.vm_bridge}" 
        firewall = "${var.vm_firewall}" 
        vlan_tag = "${var.vm_vlan_tag}" 
        packet_queues = "${var.vm_cores}"
    }

    // Packer Boot Commands
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

    // Packer Autoinstall Settings
    http_content = {
      "/meta-data" = file("http/meta-data")
      "/user-data" = templatefile("http/user-data.pkrtpl.hcl", {
      ssh_key                  = data.sshkey.packer.public_key
      build_username           = var.build_username
      vm_guest_os_language     = var.vm_guest_os_language
      vm_guest_os_keyboard     = var.vm_guest_os_keyboard
      vm_guest_os_timezone     = var.vm_guest_os_timezone
    })}
    // (Optional) Bind IP Address and Port
    http_bind_address = "${var.http_bind_address}"
    http_port_min = "${var.http_port_min}"
    http_port_max = "${var.http_port_max}"

    // (Option 1) Add your Password here
    // ssh_password = "Xm2Y6vZVcViPnhFm"
    // - or -
    // (Option 2) Add your Private SSH KEY file here
    // ssh_clear_authorized_keys = true
    ssh_username = "${var.ssh_username}"
    ssh_private_key_file = "${data.sshkey.packer.private_key_path}"
    ssh_clear_authorized_keys = "${var.ssh_clear_authorized_keys}"

    // Raise the timeout, when installation takes longer
    ssh_timeout = "${var.communicator_timeout}"
}

// Build Definition to create the VM Template
build {
    name = "ubuntu-server-jammy"
    sources = ["source.proxmox.ubuntu-server-jammy"]

    // Provisioning the VM Template for Cloud-Init Integration in Proxmox. Needs to be first.
    provisioner "shell" {
      inline = [
        "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
      ]
    }

    // Transfer config files to template
    provisioner "file" {
      source = "files/configs"
      destination = "/tmp/configs/"
    }

    // Copying configs across
    provisioner "shell" {
      inline = [
        "sudo cp /tmp/configs/00proxy /etc/apt/apt.conf.d/00proxy",
        "sudo cp /tmp/configs/51unattended-upgrades /etc/apt/apt.conf.d/51unattended-upgrades",
        "sudo cp /tmp/configs/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
      ]
    }

    # Run Provisioning Scripts
    provisioner "shell" {
      environment_vars = [
        "BUILD_USER=${var.build_username}",
        "SWAP_SIZE=${var.swap_size}",
        "POSTFIX_RELAY=${var.postfix_relay}",
        "POSTFIX_DOMAIN=${var.postfix_domain}",
        "POSTFIX_USER=${var.postfix_user}",
        "POSTFIX_PASS=${var.postfix_pass}",
      ]
      execute_command = "sudo -S env {{ .Vars }} {{ .Path }}"
      inline_shebang  = "/bin/bash -ex"
      scripts = [
        "${path.root}/files/scripts/swap.sh",
        "${path.root}/files/scripts/desktop_postinstall.sh",
        "${path.root}/files/scripts/packages.sh",
        // "${path.root}/files/scripts/docker.sh",
        "${path.root}/files/scripts/postfix.sh",
        "${path.root}/files/scripts/cleanup.sh",
      ]
    }

    // Add additional provisioning scripts here
    // ...

    // Set up Cloud-Init on Proxmox as the builder can't yet do this.
    // Be aware there are some hardcoded overrides ("discard=on,iothread=1,ssd=1"). Make sure to update as you require.
    post-processors {
      post-processor "shell-local" {
        inline = [
    // https://github.com/hashicorp/packer-plugin-proxmox/pull/90 and https://github.com/hashicorp/packer-plugin-proxmox/pull/93
          // "ssh root@proxmox qm set ${build.ID} --efidisk0 ${var.vm_cloud_init_storage_pool}:0,efitype=4m,,format=qcow2,pre-enrolled-keys=1,size=528K",
          "ssh root@proxmox qm set ${build.ID} --rng0 source=/dev/urandom",
          "ssh root@proxmox qm set ${build.ID} --agent enabled=1,fstrim_cloned_disks=1",
          "ssh root@proxmox qm set ${build.ID} --ipconfig0 ip=dhcp",
          "ssh root@proxmox qm set ${build.ID} --ciuser     ${var.vm_cloud_init_user}",
          "ssh root@proxmox qm set ${build.ID} --vga virtio-gl",
          "ssh root@proxmox qm set ${build.ID} --cipassword ${var.vm_cloud_init_pass}",
          "ssh root@proxmox qm set ${build.ID} --scsi0 ${var.vm_storage_pool}:${build.ID}/base-${build.ID}-disk-0.qcow2,cache=${var.vm_cache_mode},discard=on,iothread=1,ssd=1",
          "ssh root@proxmox qm set ${build.ID} --delete ide2", // Delete the DVD drive.
        ]
      }
    // Set Cloud-Init SSH key
      post-processor "shell-local" {
        environment_vars = ["SSH_KEY=${var.vm_cloud_init_ssh_key}"]
        inline = [
          "ssh root@proxmox \"echo $SSH_KEY > /tmp/tmpssh.pub\"",
          "ssh root@proxmox qm set ${build.ID} --sshkey /tmp/tmpssh.pub",
          "ssh root@proxmox rm -v /tmp/tmpssh.pub"
        ]
      }
    }
}
