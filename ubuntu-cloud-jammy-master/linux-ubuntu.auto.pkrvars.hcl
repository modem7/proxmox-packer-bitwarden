// https://github.com/vmware-samples/packer-examples-for-vsphere/blob/main/builds/linux/ubuntu/22-04-lts/linux-ubuntu.auto.pkrvars.hcl
// https://github.com/vmware-samples/packer-examples-for-vsphere/blob/main/builds/linux/ubuntu/22-04-lts/linux-ubuntu.pkr.hcl
// https://github.com/vmware-samples/packer-examples-for-vsphere/blob/main/builds/linux/ubuntu/22-04-lts/variables.pkr.hcl
// https://github.com/vmware-samples/packer-examples-for-vsphere/blob/main/builds/linux/ubuntu/22-04-lts/data/user-data.pkrtpl.hcl


// Look at identity and ssh authorized keys

// Proxmox Settings
node                       = "proxmox"
proxmox_host               = "192.168.0.251"
proxmox_port               = "8006"
vm_name                    = "ubuntu-server-jammy-packer"
insecure_skip_tls_verify   = "true"
unmount_iso                = "true"

// Removable Media Settings
iso_storage_pool           = "Proxmox"
iso_path                   = "Proxmox:iso"
iso_file                   = "ubuntu-22.04.1-live-server-amd64.iso"

// Guest Operating System Metadata
vm_guest_os_language       = "en_GB"
vm_guest_os_keyboard       = "gb"
vm_guest_os_timezone       = "geoip"

// Virtual Machine Hardware Settings
template_description       = "Ubuntu Server Jammy Image"
vm_os                      = "l26"
vm_qemu_agent              = "true"
vm_cloud_init              = "true"
vm_cloud_init_storage_pool = "Proxmox"
vm_cloud_init_user         = "root"
vm_cloud_init_pass         = "7kxVnxGnKadL1fFzwaGmV7lGyOEjQk" // Change this here, or in cloud-init
vm_cloud_init_ssh_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFLnUCnFyoONBwVMs1Gj4EqERx+Pc81dyhF6IuF26WM proxvms" // Add your public SSH key here for usage in cloud-init.
vm_scsi_controller         = "virtio-scsi-single"
vm_format                  = "qcow2"
// vm_id                      = "10000" // If commented out, will pick next available ID. If you want specific, uncomment this.
vm_storage_pool            = "Proxmox"
vm_storage_pool_type       = "directory"
vm_type                    = "scsi"
vm_cache_mode              = "writethrough"
vm_io_thread               = "true"
vm_cores                   = "2"
vm_packet_queues           = "" // Currently set to var.vm_cores
vm_memory                  = "2048" // Needs to be in MB.
vm_disk_size               = "15G"
vm_cpu_type                = "host"
vm_machine                 = "q35"
vm_model                   = "virtio"
vm_bridge                  = "vmbr1"
vm_firewall                = "false"
vm_vlan_tag                = "50"

// Swap Settings
swap_size                  = "2G"

// Boot Settings
vm_boot_wait               = "5s"

// Default Account Credentials
build_username             = "root"
// To create encrypted password: mkpasswd --method=SHA-512 --rounds=4096
build_password_encrypted   = ""

// Communicator Settings
communicator_timeout       = "30m"
ssh_username               = "root"
ssh_clear_authorized_keys  = "true"

// Packer Settings
// http_bind_address = "192.168.50.100"
http_bind_address          = "0.0.0.0"
http_port_min              = "8811"
http_port_max              = "8811"