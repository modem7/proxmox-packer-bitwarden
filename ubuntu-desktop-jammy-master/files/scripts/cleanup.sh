#!/bin/sh

# Cleanup Temp directories
echo "===> Cleaning up Temp Directories"
rm -rf /tmp/*
rm -rf /var/tmp/*

# Enabling FSTrim
echo "===> Enabling FSTrim"
fstrim -av
systemctl enable fstrim.timer

# Change Tuned profile
echo "===> Changing Tuned Profile"
systemctl enable --now tuned
tuned-adm profile virtual-guest

# Randomise build user password
echo "===> Randomising Build Password"
p=$(pwgen -1 -sn 32)
echo $BUILD_USER:$p | chpasswd
echo "=============================================================="
echo "===> $BUILD_USER password changed to $p"
echo "=============================================================="

# Clean up current SSH keys
echo "===> Cleaning up SSH Host Keys"
rm /etc/ssh/ssh_host_*

# Truncate machine-id
echo "===> Truncating Machine-ID"
truncate -s 0 /etc/machine-id

# Clean up Logs
echo "===> Cleaning up Logs"
service rsyslog stop
[ -f /var/log/audit/audit.log ] && sudo truncate -s 0 /var/log/audit/audit.log
[ -f /var/log/wtmp ] && sudo truncate -s 0 /var/log/wtmp
[ -f /var/log/lastlog ] && sudo truncate -s 0 /var/log/lastlog

# Clean up persistent udev rules
echo "===> Cleaning up udev rules"
[ -f /etc/udev/rules.d/70-persistent-net.rules ] && sudo rm -fv /etc/udev/rules.d/70-persistent-net.rules

# Delete cloudinit-networking.cfg
echo "===> Deleting cloud-init networking"
[ -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg ] && sudo rm -fv /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg

# Clean APT
echo "===> Cleaning APT"
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean
cloud-init clean
sync
