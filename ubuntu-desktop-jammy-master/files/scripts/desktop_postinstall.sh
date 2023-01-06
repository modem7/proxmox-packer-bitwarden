#!/bin/bash

# Desktop Cleanup
# Enable the boot splash
sed -i /etc/default/grub -e 's/GRUB_CMDLINE_LINUX_DEFAULT=".*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/'
update-grub

# Remove default filesystem and related tools not used with the suggested
# 'direct' storage layout.  These may yet be required if different
# partitioning schemes are used.
apt-get remove -y \
        btrfs-progs \
        cryptsetup* \
        lvm2 \
        xfsprogs

# Remove other packages present by default in Ubuntu Server but not
# normally present in Ubuntu Desktop.
apt-get remove -y \
        ubuntu-server \
        ubuntu-server-minimal \
        binutils \
        byobu \
        curl \
        dmeventd \
        finalrd \
        gawk \
        kpartx \
        mdadm \
        ncurses-term \
        open-iscsi \
        sg3-utils \
        sssd \
        thin-provisioning-tools \
        vim \
        tmux \
        sosreport \
        screen \
        open-vm-tools \
        motd-news-config \
        lxd-agent-loader \
        landscape-common \
        htop \
        git \
        fonts-ubuntu-console \
        ethtool