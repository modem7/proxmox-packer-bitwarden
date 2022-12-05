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
  packages:
    - qemu-guest-agent
    - sudo
    - bash-completion
    - cloud-init
    - cloud-utils
    - cloud-guest-utils
    - git
    - curl
    - mlocate
    - resolvconf
    - htop
    - net-tools
    - dnsutils
    - aptitude
    - unzip
    - tuned
    - tuned-utils
    - tuned-utils-systemtap
    - tldr
    - needrestart
    - acl
    - libsasl2-modules
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
  late-commands:
    - sed -i '/^\/swap.img/d' /target/etc/fstab
    - swapoff -a
    - rm -rf /target/swap.img
