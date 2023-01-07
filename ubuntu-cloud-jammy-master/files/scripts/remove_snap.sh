#!/bin/bash

# Remove Snap
echo "===> Removing Snap"
systemctl disable --now snapd

apt-get autoremove -y --purge \
        snapd                 \
        gnome-software-plugin-snap

rm -rf               \
    /snap            \
    /var/snap        \
    /var/lib/snapd   \
    /var/cache/snapd \
    /usr/lib/snapd   \
    ~/snap

apt-mark hold snapd

# Stop it from being reinstalled by 'mistake' when installing other packages
echo "===> Stopping Snap from being reinstalled"
tee /etc/apt/preferences.d/no-snap.pref >/dev/null << EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

systemctl daemon-reload

exit 0
