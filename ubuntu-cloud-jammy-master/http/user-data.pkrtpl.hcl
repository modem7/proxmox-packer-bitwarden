#cloud-config
autoinstall:
  version: 1
  refresh-installer:
    update: true
    channel: stable
  locale: ${vm_guest_os_language}
  keyboard:
    layout: ${vm_guest_os_keyboard}
  apt:
    geoip: true
    preserve_sources_list: false
  ssh:
    install-server: true
    allow-pw: true
    disable_root: false
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  package_update: true
  package_upgrade: true
  package_reboot_if_required: true
  updates: all
  packages: # Basic Packages. Additional can be installed via packages.sh script.
    - cloud-guest-utils
    - cloud-init
    - cloud-utils
    - qemu-guest-agent
    - tuned
    - tuned-utils
    - tuned-utils-systemtap
  storage:
    layout:
      name: direct
  user-data:
    disable_root: false
    timezone: ${vm_guest_os_timezone}
    users:
      - name: root # Using root as it won't create a new user. We'll leave that up to cloud-init.
        shell: /bin/bash
        ssh_authorized_keys:
         - ${ssh_key}
      - name: ansible # https://cloudinit.readthedocs.io/en/latest/topics/examples.html#configure-instance-to-be-managed-by-ansible
        gecos: Ansible User
        groups: sudo
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        lock_passwd: true
        ssh_authorized_keys:
          - ${ssh_key}
  late-commands:
    - sed -i '/^\/swap.img/d' /target/etc/fstab
    - swapoff -a
    - rm -rf /target/swap.img
