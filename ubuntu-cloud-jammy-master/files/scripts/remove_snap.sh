#!/bin/bash

# Remove Snap
echo "===> Removing Snap"
rm -rf /var/cache/snapd
apt-get autoremove -y --purge snapd gnome-software-plugin-snap
rm -rf ~/snap
apt-mark hold snapd
systemctl daemon-reload