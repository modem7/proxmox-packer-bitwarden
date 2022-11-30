#cloud-config
autoinstall:
  version: 1
  refresh-installer:
    update: true
    channel: stable
  locale: en_GB
  keyboard:
    layout: gb
  apt:
    geoip: true
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
    timezone: geoip
    users:
      - name: packer
        gecos: Packer User
        no_user_group: true
        groups: [adm, sudo]
        lock-passwd: true
        homedir: /tmp/packer
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
         - ${ssh_key}
  late-commands:
    - sed -i '/^\/swap.img/d' /target/etc/fstab
    - swapoff -a
    - rm -rf /target/swap.img


